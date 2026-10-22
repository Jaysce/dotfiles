#Requires -Version 5.1
[CmdletBinding()]
param([string]$DotfilesPath)

function Update-SessionPath {
    $env:Path = (@(
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:Path
    ) -split [IO.Path]::PathSeparator | Where-Object { $_ } | Select-Object -Unique) -join [IO.Path]::PathSeparator
}

function Invoke-CheckedCommand {
    param([string]$FilePath, [string[]]$Arguments, [int[]]$SuccessCodes = @(0))

    & $FilePath @Arguments
    if ($LASTEXITCODE -notin $SuccessCodes) {
        throw "$FilePath failed with exit code $LASTEXITCODE."
    }
}

function Invoke-SetupStep {
    param([string]$Name, [scriptblock]$Action)

    Write-Host "`n$Name..."
    try {
        & $Action
    } catch {
        $script:errorLog += "${Name}: $_"
        Write-Warning $script:errorLog[-1]
    }
}

function Initialize-WinGet {
    Update-SessionPath
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        try {
            Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
        } catch {
            Write-Host 'App Installer registration unavailable. Bootstrapping WinGet with Microsoft.WinGet.Client.'
        }
        Update-SessionPath
    }
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
        }
        Install-Module Microsoft.WinGet.Client -Repository PSGallery -Scope CurrentUser -Force
        Import-Module Microsoft.WinGet.Client
        Repair-WinGetPackageManager -Latest
        Update-SessionPath
    }
    Invoke-CheckedCommand winget.exe @('--version')
}

function Install-Application {
    param([string]$Id)

    $installed = & winget.exe list --id $Id --exact --source winget --accept-source-agreements --disable-interactivity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$Id is already installed."
        return
    }
    if ($LASTEXITCODE -ne -1978335212) {
        throw "Cannot check ${Id}: $installed (exit code $LASTEXITCODE)."
    }
    # WinGet returns PACKAGE_ALREADY_INSTALLED when --no-upgrade skips an existing package.
    Invoke-CheckedCommand winget.exe @(
        'install', '--id', $Id, '--exact', '--source', 'winget', '--no-upgrade',
        '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity'
    ) @(0, -1978335135)
}

function Install-Applications {
    $apps = @(
        'Git.Git', 'GitHub.cli', 'GitHub.GitHubDesktop', 'Microsoft.VisualStudioCode',
        'Neovim.Neovim', 'Microsoft.PowerShell', 'Microsoft.WindowsTerminal',
        'cURL.cURL', 'jqlang.jq', 'sharkdp.bat', 'Starship.Starship', 'dandavison.delta',
        'DEVCOM.JetBrainsMonoNerdFont', 'AgileBits.1Password', 'Spotify.Spotify',
        'Discord.Discord', 'Valve.Steam', 'xanderfrangos.twinkletray',
        'Microsoft.PowerToys', 'RamenSoftware.Windhawk'
    )
    foreach ($app in $apps) {
        Invoke-SetupStep "Install $app" { Install-Application $app }
    }
    Update-SessionPath
}

function Install-Dotfiles {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        Invoke-CheckedCommand git.exe @('clone', 'https://github.com/Jaysce/dotfiles.git', $Path)
    }
    foreach ($relativePath in @(
        'other/powershell/Microsoft.PowerShell_profile.ps1', 'common/.config/starship',
        'common/.gitconfig', 'common/.ideavimrc'
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Path $relativePath))) {
            throw "Missing dotfile $relativePath in $Path. Existing directories are never overwritten."
        }
    }
    Write-Host "Using dotfiles at $Path."
}

function Get-PowerShellProfiles {
    $shells = @(
        (Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe')
        (Get-Command pwsh.exe -CommandType Application -ErrorAction Stop).Source
    )
    foreach ($shell in $shells) {
        $command = @'
$ErrorActionPreference = 'Stop'
try {
    foreach ($scope in @('MachinePolicy', 'UserPolicy')) {
        if ((Get-ExecutionPolicy -Scope $scope) -notin @('Undefined', 'Bypass', 'Unrestricted', 'RemoteSigned')) {
            throw "Execution policy is managed by $scope. Contact your administrator."
        }
    }
    Remove-Item Env:\PSExecutionPolicyPreference -ErrorAction SilentlyContinue
    if ((Get-ExecutionPolicy -Scope CurrentUser) -ne 'RemoteSigned') {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    }
    $PROFILE.CurrentUserCurrentHost
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
'@
        $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
        Invoke-CheckedCommand $shell @('-NoLogo', '-NoProfile', '-NonInteractive', '-EncodedCommand', $encodedCommand)
    }
}

function Set-DotfileLink {
    param([string]$Path, [string]$Target)

    if (-not (Test-Path -LiteralPath $Target)) {
        throw "Cannot link $Path. Target does not exist: $Target."
    }
    $Target = (Get-Item -LiteralPath $Target -Force).FullName
    $existing = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and @($existing.Target)[0] -eq $Target) {
        Write-Host "Link already correct: $Path"
        return
    }
    $backup = $null
    if ($existing) {
        $backup = "$Path.backup-$(Get-Date -Format 'yyyyMMddHHmmssfff')-$([guid]::NewGuid().ToString('N'))"
        Move-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up $Path to $backup."
    }
    try {
        New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop | Out-Null
    } catch {
        if ($backup) {
            Move-Item -LiteralPath $backup -Destination $Path
        }
        throw
    }
    Write-Host "Linked $Path to $Target."
}

function Start-AdminContext {
    param([string]$Code)

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    if ($isAdmin) {
        & ([scriptblock]::Create($Code))
        return
    }
    $errorPath = [IO.Path]::GetTempFileName()
    try {
        $quotedErrorPath = $errorPath.Replace("'", "''")
        $wrappedCode = "`$ErrorActionPreference = 'Stop'; try { $Code } catch { [IO.File]::WriteAllText('$quotedErrorPath', `$_.ToString()); exit 1 }"
        $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($wrappedCode))
        $process = Start-Process -FilePath (Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe') -Verb RunAs -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encodedCommand
        ) -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            $detail = Get-Content -LiteralPath $errorPath -Raw
            throw "Administrator setup failed with exit code $($process.ExitCode): $detail"
        }
    } finally {
        Remove-Item -LiteralPath $errorPath -Force -ErrorAction SilentlyContinue
    }
}

function Enable-UltimatePerformance {
    $guid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
    $plans = & powercfg.exe /list
    if ($LASTEXITCODE -ne 0) { throw 'Cannot list power plans.' }
    if (-not ($plans -match $guid)) {
        $output = & powercfg.exe /duplicatescheme $guid $guid 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Ultimate Performance is unavailable on this hardware: $output"
            return
        }
    }
    $active = & powercfg.exe /getactivescheme
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read active power plan.' }
    if (-not ($active -match $guid)) {
        Invoke-CheckedCommand powercfg.exe @('/setactive', $guid)
    }
}

function Set-SystemProductName {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    New-ItemProperty -Path $path -Name Model -Value "Sasindu's PC" -PropertyType String -Force | Out-Null
}

function Set-DotfilesAndMachineSettings {
    param([object[]]$Links)

    # Resolve user paths before elevation, which may run as a different administrator.
    $linksJson = (ConvertTo-Json -InputObject @($Links) -Compress).Replace("'", "''")
    $code = @"
function Set-DotfileLink { ${function:Set-DotfileLink} }
function Invoke-CheckedCommand { ${function:Invoke-CheckedCommand} }
function Enable-UltimatePerformance { ${function:Enable-UltimatePerformance} }
function Set-SystemProductName { ${function:Set-SystemProductName} }
`$failures = @()
foreach (`$link in (ConvertFrom-Json '$linksJson')) {
    try { Set-DotfileLink -Path `$link.Path -Target `$link.Target } catch { `$failures += "`$_" }
}
try { Enable-UltimatePerformance } catch { `$failures += "`$_" }
try { Set-SystemProductName } catch { `$failures += "`$_" }
if (`$failures.Count) { throw (`$failures -join [Environment]::NewLine) }
"@
    Start-AdminContext $code
}

function Set-UserSettings {
    $recycleBinGuid = '{645FF040-5081-101B-9F08-00AA002F954E}'
    $settings = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name = $recycleBinGuid; Value = 1 }
        @{ Path = "HKCU:\SOFTWARE\Classes\CLSID\$recycleBinGuid"; Name = 'System.IsPinnedToNameSpaceTree'; Value = 1 }
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'BingSearchEnabled'; Value = 0 }
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'; Name = 'CortanaConsent'; Value = 0 }
    )
    foreach ($setting in $settings) {
        if (-not (Test-Path $setting.Path)) {
            New-Item -Path $setting.Path -Force | Out-Null
        }
        New-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -PropertyType DWord -Force | Out-Null
    }
    Write-Host 'Explorer settings apply after signing out and back in.'
}

function Set-TerminalProfile {
    $fragmentPath = Join-Path $env:LOCALAPPDATA 'Microsoft/Windows Terminal/Fragments/Dotfiles/powershell.json'
    $pwsh = (Get-Command pwsh.exe -CommandType Application -ErrorAction Stop).Source
    $json = [ordered]@{
        profiles = @(
            [ordered]@{
                updates = '{574e775e-4f2a-5b96-ac1e-a2962a402336}'
                commandline = '"' + $pwsh + '" -NoLogo'
                font = [ordered]@{ face = 'JetBrainsMono Nerd Font' }
            }
            [ordered]@{
                updates = '{61c54bbd-c2c6-5271-96e7-009a87ff44bf}'
                font = [ordered]@{ face = 'JetBrainsMono Nerd Font' }
            }
        )
    } | ConvertTo-Json -Depth 5
    if ((Test-Path -LiteralPath $fragmentPath) -and (Get-Content -LiteralPath $fragmentPath -Raw) -eq $json) {
        Write-Host 'Windows Terminal profile is already configured.'
        return
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $fragmentPath) -Force | Out-Null
    [IO.File]::WriteAllText($fragmentPath, $json, (New-Object Text.UTF8Encoding $false))
    Write-Host 'Windows Terminal PowerShell 7 profile configured. Restart Terminal to load it.'
}

function Invoke-WindowsSetup {
    param([string]$Path)

    $ErrorActionPreference = 'Stop'
    $script:errorLog = @()
    if ([Environment]::OSVersion.Platform -ne 'Win32NT') {
        throw 'This setup requires Windows. Run scripts\windows11-setup.cmd on Windows 11.'
    }
    if (-not $Path) {
        $checkout = Split-Path -Parent $PSScriptRoot
        if (Test-Path -LiteralPath (Join-Path $checkout 'common/.gitconfig')) {
            $Path = $checkout
        } else {
            $Path = Join-Path $HOME 'dotfiles'
        }
    }
    $Path = [IO.Path]::GetFullPath($Path)
    Initialize-WinGet
    Install-Applications
    Install-Dotfiles $Path
    $links = @(
        @{ Path = (Join-Path $HOME '.config/starship'); Target = (Join-Path $Path 'common/.config/starship') }
        @{ Path = (Join-Path $HOME '.gitconfig'); Target = (Join-Path $Path 'common/.gitconfig') }
        @{ Path = (Join-Path $HOME '.ideavimrc'); Target = (Join-Path $Path 'common/.ideavimrc') }
    )
    $profileSource = Join-Path $Path 'other/powershell/Microsoft.PowerShell_profile.ps1'
    $profilePaths = @(Invoke-SetupStep 'Configure PowerShell profiles and execution policies' {
        Unblock-File -LiteralPath $profileSource
        Get-PowerShellProfiles
    })
    foreach ($profilePath in ($profilePaths | Select-Object -Unique)) {
        $links += @{ Path = $profilePath; Target = $profileSource }
    }
    Invoke-SetupStep 'Link dotfiles and configure machine settings (UAC approval may be required)' {
        Set-DotfilesAndMachineSettings $links
    }
    Invoke-SetupStep 'Configure Windows Terminal' { Set-TerminalProfile }
    Invoke-SetupStep 'Configure Explorer and search' { Set-UserSettings }
    if ($script:errorLog.Count) {
        throw ("Setup finished with errors. Rerun after resolving them:`n" + ($script:errorLog -join "`n"))
    }
    Write-Host "`nSetup completed. Open a new Terminal tab and select PowerShell to use PowerShell 7."
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-WindowsSetup $DotfilesPath
    } catch {
        Write-Error $_ -ErrorAction Continue
        exit 1
    }
}
