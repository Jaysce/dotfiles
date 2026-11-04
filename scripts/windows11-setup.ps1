#Requires -Version 5.1
# Run on a fresh install from PowerShell:
# Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/windows11-setup.ps1 | iex
[CmdletBinding()]
param()

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
        'AgileBits.1Password', 'Spotify.Spotify', 'Discord.Discord', 'Valve.Steam',
        'xanderfrangos.twinkletray'
    )
    foreach ($app in $apps) {
        Invoke-SetupStep "Install $app" { Install-Application $app }
    }
    Update-SessionPath
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

function Set-MachineSettings {
    $code = @"
function Invoke-CheckedCommand { ${function:Invoke-CheckedCommand} }
function Enable-UltimatePerformance { ${function:Enable-UltimatePerformance} }
function Set-SystemProductName { ${function:Set-SystemProductName} }
`$failures = @()
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

function Invoke-WindowsSetup {
    $ErrorActionPreference = 'Stop'
    $script:errorLog = @()
    if ([Environment]::OSVersion.Platform -ne 'Win32NT') {
        throw 'This setup requires Windows 11.'
    }
    Initialize-WinGet
    Install-Applications
    Invoke-SetupStep 'Configure machine settings (UAC approval may be required)' { Set-MachineSettings }
    Invoke-SetupStep 'Configure Explorer and search' { Set-UserSettings }
    if ($script:errorLog.Count) {
        throw ("Setup finished with errors. Rerun after resolving them:`n" + ($script:errorLog -join "`n"))
    }
    Write-Host "`nSetup completed."
}

if ($MyInvocation.InvocationName -ne '.') {
    try {
        Invoke-WindowsSetup
    } catch {
        Write-Error $_ -ErrorAction Continue
        # Under Invoke-Expression there is no script file, and exit would close the caller's session.
        if ($PSCommandPath) { exit 1 }
    }
}
