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
Test-Case 'installed application is skipped' {
    function winget.exe {
        if ($args[0] -ne 'list') { throw 'Installed app must not be installed again.' }
        $global:LASTEXITCODE = 0
    }
    Install-Application Valve.Steam
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
    Install-Application Valve.Steam
    Install-Application Valve.Steam
    Assert ($script:installCount -eq 1) 'Rerun must skip the installed application.'
}

Test-Case 'WinGet failures propagate and are not treated as missing packages' {
    function winget.exe {
        if ($args[0] -ne 'list') { throw 'Failed lookup must not trigger installation.' }
        $global:LASTEXITCODE = -1978335163
        'Source is unavailable.'
    }
    Assert-Throws { Install-Application Valve.Steam } 'Source failures must propagate.'
}

Test-Case 'native installation failures propagate' {
    function winget.exe {
        if ($args[0] -eq 'list') { $global:LASTEXITCODE = -1978335212 }
        else { $global:LASTEXITCODE = 123 }
    }
    Assert-Throws { Install-Application Valve.Steam } 'Installer failures must propagate.'
}

Test-Case 'already-installed race is accepted by no-upgrade installation' {
    function winget.exe {
        if ($args[0] -eq 'list') { $global:LASTEXITCODE = -1978335212 }
        else { $global:LASTEXITCODE = -1978335135 }
    }
    Install-Application Valve.Steam
}

Test-Case 'elevated batch is valid PowerShell and stays within command length limits' {
    function Start-AdminContext {
        param([string]$Code)
        $script:elevatedCode = $Code
    }
    Set-MachineSettings
    $length = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script:elevatedCode)).Length
    Assert ($length -lt 30000) 'Encoded command must fit the Windows command line limit.'
    [scriptblock]::Create($script:elevatedCode) | Out-Null
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

Write-Host "$script:passed tests passed. Windows installers, registry, and UAC need Windows verification."
