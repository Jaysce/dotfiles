#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '../windows11-setup.ps1')

function Assert {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Message)
    $threw = $false
    try { & $Action } catch { $threw = $true }
    Assert $threw $Message
}

function Test-Case {
    param([string]$Name, [scriptblock]$Action)
    & $Action
    Write-Host "PASS $Name"
    $script:passed++
}

$script:passed = 0
$scratch = Join-Path ([IO.Path]::GetTempPath()) "windows11-setup-tests-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $scratch | Out-Null
$originalLocalAppData = $env:LOCALAPPDATA
try {
    Test-Case 'existing checkout is reused without calling Git' {
        function git.exe { throw 'Existing checkout must not be cloned.' }
        Install-Dotfiles (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    }

    Test-Case 'incomplete existing checkout is preserved and rejected' {
        $checkout = Join-Path $scratch 'incomplete'
        New-Item -ItemType Directory -Path $checkout | Out-Null
        Set-Content -LiteralPath (Join-Path $checkout 'keep.txt') -Value 'preserved'
        function git.exe { throw 'Existing directory must not be cloned into.' }
        Assert-Throws { Install-Dotfiles $checkout } 'Incomplete checkout must be rejected.'
        Assert ((Get-Content -LiteralPath (Join-Path $checkout 'keep.txt')) -eq 'preserved') 'Checkout contents must survive.'
    }

    Test-Case 'file link preserves existing settings and is unchanged on rerun' {
        $target = Join-Path $scratch 'source file.txt'
        $link = Join-Path $scratch 'existing file.txt'
        Set-Content -LiteralPath $target -Value 'managed'
        Set-Content -LiteralPath $link -Value 'original'
        Set-DotfileLink $link $target
        $firstWrite = (Get-Item -LiteralPath $link -Force).LastWriteTimeUtc
        Set-DotfileLink $link $target
        Assert ((Get-Item -LiteralPath $link -Force).LinkType -eq 'SymbolicLink') 'Config must be a symbolic link.'
        Assert ((Get-Content -LiteralPath $link) -eq 'managed') 'Link must read the managed config.'
        $backups = @(Get-ChildItem -LiteralPath $scratch -Filter 'existing file.txt.backup-*')
        Assert ($backups.Count -eq 1) 'Rerun must not create another backup.'
        Assert ((Get-Content -LiteralPath $backups[0].FullName) -eq 'original') 'Original config must survive in its backup.'
        Assert ((Get-Item -LiteralPath $link -Force).LastWriteTimeUtc -eq $firstWrite) 'Rerun must not replace the correct link.'
    }

    Test-Case 'missing target leaves an existing config untouched' {
        $path = Join-Path $scratch 'preserved.txt'
        Set-Content -LiteralPath $path -Value 'original'
        Assert-Throws { Set-DotfileLink $path (Join-Path $scratch 'missing') } 'Missing targets must fail.'
        Assert ((Get-Content -LiteralPath $path) -eq 'original') 'Missing target must not remove existing config.'
    }

    Test-Case 'broken symbolic link is repaired' {
        $link = Join-Path $scratch 'broken.txt'
        $target = Join-Path $scratch 'repaired.txt'
        Set-Content -LiteralPath $target -Value 'repaired'
        New-Item -ItemType SymbolicLink -Path $link -Target (Join-Path $scratch 'absent.txt') | Out-Null
        Set-DotfileLink $link $target
        Set-DotfileLink $link $target
        Assert ((Get-Content -LiteralPath $link) -eq 'repaired') 'Broken link must point to the new source.'
    }

    Test-Case 'directory link preserves an existing directory and creates missing parents' {
        $target = Join-Path $scratch 'source directory'
        $link = Join-Path $scratch 'directory'
        New-Item -ItemType Directory -Path $target, $link | Out-Null
        Set-Content -LiteralPath (Join-Path $link 'keep.txt') -Value 'original'
        Set-DotfileLink $link $target
        Set-DotfileLink $link $target
        $backups = @(Get-ChildItem -LiteralPath $scratch -Filter 'directory.backup-*')
        Assert ($backups.Count -eq 1) 'Directory rerun must not create duplicate backups.'
        Assert (Test-Path -LiteralPath (Join-Path $backups[0].FullName 'keep.txt')) 'Directory contents must be backed up.'
        $nested = Join-Path $scratch 'new/parents/starship'
        Set-DotfileLink $nested $target
        Assert ((Get-Item -LiteralPath $nested -Force).LinkType -eq 'SymbolicLink') 'Missing parents must be created.'
    }

    Test-Case 'failed link creation restores the original file' {
        $path = Join-Path $scratch 'rollback.txt'
        $target = Join-Path $scratch 'source file.txt'
        Set-Content -LiteralPath $path -Value 'original'
        function New-Item {
            param($ItemType, $Path, $Target, [switch]$Force, $ErrorAction)
            if ($ItemType -eq 'SymbolicLink') { throw 'Simulated privilege failure.' }
            Microsoft.PowerShell.Management\New-Item -ItemType $ItemType -Path $Path -Force:$Force
        }
        Assert-Throws { Set-DotfileLink $path $target } 'Link creation failure must propagate.'
        Assert ((Get-Content -LiteralPath $path) -eq 'original') 'Original file must be restored after failure.'
    }

    Test-Case 'installed application is skipped' {
        function winget.exe {
            if ($args[0] -ne 'list') { throw 'Installed app must not be installed again.' }
            $global:LASTEXITCODE = 0
        }
        Install-Application Git.Git
    }

    Test-Case 'missing application installs once and rerun skips it' {
        $script:installed = $false
        $script:installCount = 0
        function winget.exe {
            if ($args[0] -eq 'list') {
                if ($script:installed) { $global:LASTEXITCODE = 0 } else { $global:LASTEXITCODE = -1978335212 }
            } else {
                Assert ($args -contains '--no-upgrade') 'Install must disable automatic upgrades.'
                $script:installed = $true
                $script:installCount++
                $global:LASTEXITCODE = 0
            }
        }
        Install-Application Git.Git
        Install-Application Git.Git
        Assert ($script:installCount -eq 1) 'Rerun must skip the installed application.'
    }

    Test-Case 'WinGet failures propagate and are not treated as missing packages' {
        function winget.exe {
            if ($args[0] -ne 'list') { throw 'Failed lookup must not trigger installation.' }
            $global:LASTEXITCODE = -1978335163
            'Source is unavailable.'
        }
        Assert-Throws { Install-Application Git.Git } 'Source failures must propagate.'
    }

    Test-Case 'native installation failures propagate' {
        function winget.exe {
            if ($args[0] -eq 'list') { $global:LASTEXITCODE = -1978335212 }
            else { $global:LASTEXITCODE = 123 }
        }
        Assert-Throws { Install-Application Git.Git } 'Installer failures must propagate.'
    }

    Test-Case 'already-installed race is accepted by no-upgrade installation' {
        function winget.exe {
            if ($args[0] -eq 'list') { $global:LASTEXITCODE = -1978335212 }
            else { $global:LASTEXITCODE = -1978335135 }
        }
        Install-Application Git.Git
    }

    Test-Case 'Terminal fragment is stable and preserves existing Terminal settings' {
        $env:LOCALAPPDATA = Join-Path $scratch 'local app data'
        function Get-Command { [pscustomobject]@{ Source = 'C:\Program Files\PowerShell\7\pwsh.exe' } }
        $settingsPath = Join-Path $env:LOCALAPPDATA 'Microsoft/Windows Terminal/settings.json'
        New-Item -ItemType Directory -Path (Split-Path -Parent $settingsPath) -Force | Out-Null
        Set-Content -LiteralPath $settingsPath -Value '// user settings with comments'
        Set-TerminalProfile
        $fragmentPath = Join-Path $env:LOCALAPPDATA 'Microsoft/Windows Terminal/Fragments/Dotfiles/powershell.json'
        $firstWrite = (Get-Item -LiteralPath $fragmentPath).LastWriteTimeUtc
        Set-TerminalProfile
        $fragment = Get-Content -LiteralPath $fragmentPath -Raw | ConvertFrom-Json
        Assert ($fragment.profiles.Count -eq 2) 'Fragment must configure both PowerShell profiles.'
        Assert ($fragment.profiles[0].font.face -eq 'JetBrainsMono Nerd Font') 'Profile must use the installed Nerd Font.'
        Assert ($fragment.profiles[0].commandline -eq '"C:\Program Files\PowerShell\7\pwsh.exe" -NoLogo') 'Executable path must be quoted.'
        Assert ((Get-Item -LiteralPath $fragmentPath).LastWriteTimeUtc -eq $firstWrite) 'Rerun must not rewrite the fragment.'
        Assert ((Get-Content -LiteralPath $settingsPath) -eq '// user settings with comments') 'Existing Terminal settings must be preserved.'
    }

    Test-Case 'elevated batch preserves paths containing quotes and stays within command length limits' {
        function Start-AdminContext {
            param([string]$Code)
            $script:elevatedCode = $Code
        }
        $target = Join-Path $scratch 'source file.txt'
        $path = Join-Path $scratch "user's config.txt"
        Set-DotfilesAndMachineSettings @(@{ Path = $path; Target = $target })
        $length = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script:elevatedCode)).Length
        Assert ($length -lt 30000) 'Encoded command must fit the Windows command line limit.'
        $body = [scriptblock]::Create($script:elevatedCode.Replace('try { Enable-UltimatePerformance }', 'try { }').Replace('try { Set-SystemProductName }', 'try { }'))
        & $body
        Assert ((Get-Content -LiteralPath $path) -eq 'managed') 'Elevated batch must preserve literal user paths.'
    }

    Test-Case 'both shells use their own profile paths and persist policy only once' {
        $originalSystemRoot = $env:SystemRoot
        $originalPolicy = $env:PSExecutionPolicyPreference
        try {
            $env:SystemRoot = $scratch
            $script:shellPolicies = @{}
            $script:policyWrites = 0
            function Get-Command { [pscustomobject]@{ Source = 'PowerShell7.exe' } }
            function Get-ExecutionPolicy {
                param($Scope)
                if ($Scope -eq 'CurrentUser' -and $script:shellPolicies.ContainsKey($FilePath)) {
                    return $script:shellPolicies[$FilePath]
                }
                'Undefined'
            }
            function Set-ExecutionPolicy {
                param($ExecutionPolicy, $Scope, [switch]$Force)
                Assert (-not $env:PSExecutionPolicyPreference) 'Inherited process bypass must be cleared before persisting policy.'
                Assert ($Scope -eq 'CurrentUser') 'Policy must apply only to the current user.'
                $script:shellPolicies[$FilePath] = $ExecutionPolicy
                $script:policyWrites++
            }
            function Invoke-CheckedCommand {
                param($FilePath, $Arguments)
                $PROFILE = [pscustomobject]@{ CurrentUserCurrentHost = "$FilePath/Documents/profile.ps1" }
                Assert ($Arguments[-2] -eq '-EncodedCommand') 'Child command must avoid native quoting ambiguity.'
                $command = [Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Arguments[-1]))
                & ([scriptblock]::Create($command))
            }
            $env:PSExecutionPolicyPreference = 'Bypass'
            $profiles = @(Get-PowerShellProfiles)
            Assert ($profiles.Count -eq 2) 'Both PowerShell editions must have a profile.'
            Assert ($profiles[0] -ne $profiles[1]) 'Redirected Documents paths must come from each shell.'
            Get-PowerShellProfiles | Out-Null
            Assert ($script:policyWrites -eq 2) 'Rerun must not reset policies that are already configured.'
        } finally {
            $env:SystemRoot = $originalSystemRoot
            $env:PSExecutionPolicyPreference = $originalPolicy
        }
    }

    Test-Case 'power plan is created once with a stable GUID and rerun is unchanged' {
        $script:planExists = $false
        $script:planActive = $false
        $script:planCreates = 0
        $script:planActivations = 0
        function powercfg.exe {
            $global:LASTEXITCODE = 0
            switch ($args[0]) {
                '/list' { if ($script:planExists) { 'e9a42b02-d5df-448d-aa00-03f14749eb61 (Localized name)' } }
                '/duplicatescheme' {
                    Assert ($args[1] -eq $args[2]) 'Power plan must have a deterministic destination GUID.'
                    $script:planExists = $true
                    $script:planCreates++
                }
                '/getactivescheme' { if ($script:planActive) { 'e9a42b02-d5df-448d-aa00-03f14749eb61' } }
                '/setactive' { $script:planActive = $true; $script:planActivations++ }
                default { throw 'Unexpected powercfg operation.' }
            }
        }
        Enable-UltimatePerformance
        Enable-UltimatePerformance
        Assert ($script:planCreates -eq 1) 'Rerun must not duplicate the power plan.'
        Assert ($script:planActivations -eq 1) 'Already active plan must not be reactivated.'
    }

    Test-Case 'unsupported power plan produces a warning and is not activated' {
        function powercfg.exe {
            if ($args[0] -eq '/list') { $global:LASTEXITCODE = 0 }
            elseif ($args[0] -eq '/duplicatescheme') { $global:LASTEXITCODE = 1 }
            else { throw 'Unsupported plan must not be activated.' }
        }
        Enable-UltimatePerformance -WarningVariable warnings -WarningAction SilentlyContinue
        Assert (@($warnings).Count -eq 1) 'Unsupported hardware must produce a warning.'
    }

    Test-Case 'step failures are recorded while independent steps can continue' {
        $script:errorLog = @()
        Invoke-SetupStep 'Failed operation' { throw 'Simulated installer failure.' } -WarningAction SilentlyContinue
        $result = Invoke-SetupStep 'Independent operation' { 'continued' }
        Assert ($script:errorLog.Count -eq 1) 'Failed operation must be included in the error summary.'
        Assert ($script:errorLog[0] -match 'Simulated installer failure') 'Error summary must preserve the cause.'
        Assert ($result -eq 'continued') 'Independent steps must still run.'
    }

    Test-Case 'PowerShell profile loads when optional commands are missing' {
        function Get-Command { $null }
        . (Join-Path $PSScriptRoot '../../other/powershell/Microsoft.PowerShell_profile.ps1')
        Assert ((Get-Alias open).Definition -eq 'Invoke-Item') 'Open alias must resolve to the cmdlet.'
    }

    Write-Host "$script:passed tests passed. Windows installers, execution policy, registry, UAC, and Terminal UI need Windows verification."
} finally {
    $env:LOCALAPPDATA = $originalLocalAppData
    Remove-Item -LiteralPath $scratch -Recurse -Force
}
