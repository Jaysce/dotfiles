# Create an array to store errors
$errorLog = @()

function Initialize-Environment {
    Write-Output "`nInitializing environment..."
    # Change to user's home directory
    Set-Location ~
    # Set PowerShell execution policy
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
}

function Install-Applications {
    Write-Output "`nInstalling applications..."
    $apps = @(
        # Dev Tools
        @{name = "Git"; id = "Git.Git"},
        @{name = "GitHub CLI"; id = "GitHub.cli"},
        @{name = "GitHub Desktop"; id = "GitHub.GitHubDesktop"},
        @{name = "VS Code"; id = "Microsoft.VisualStudioCode"},
        @{name = "Neovim"; id = "Neovim.Neovim"},
        @{name = "PowerShell"; id = "Microsoft.PowerShell"},
        
        # Terminal Utilities
        @{name = "curl"; id = "cURL.cURL"},
        @{name = "jq"; id = "jqlang.jq"},
        @{name = "Starship"; id = "Starship.Starship"},
        @{name = "Delta"; id = "dandavison.delta"},
        
        # Fonts
        @{name = "JetBrains Mono Nerd Font"; id = "DEVCOM.JetBrainsMonoNerdFont"},
        
        # GUI Applications
        @{name = "1Password"; id = "AgileBits.1Password"},
        @{name = "Spotify"; id = "Spotify.Spotify"},
        @{name = "Discord"; id = "Discord.Discord"},
        @{name = "Steam"; id = "Valve.Steam"},
        @{name = "Twinkle Tray"; id = "xanderfrangos.twinkletray"},
        @{name = "PowerToys"; id = "Microsoft.PowerToys"}
    )

    foreach ($app in $apps) {
        Write-Output "Installing $($app.name)..."
        winget install -e --id $app.id --accept-package-agreements --accept-source-agreements
    }
}

function Install-Dotfiles {
    Write-Output "`nCloning dotfiles repository..."
    try {
        Set-Location ~
        git clone https://github.com/Jaysce/dotfiles.git
        Write-Output "Dotfiles cloned successfully."
    } catch {
        $script:errorLog += "Failed to clone dotfiles: $_"
    }
}

function Set-PowerShellProfile {
    Write-Output "`nSetting up PowerShell profile..."
    try {
        $profileDir = Split-Path -Parent $PROFILE
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force
        }

        if (Test-Path $PROFILE) {
            Remove-Item $PROFILE -Force
        }

        $sourcePath = Join-Path -Path $HOME -ChildPath "dotfiles\Config\powershell\user_profile.ps1"
        New-Item -ItemType SymbolicLink -Path $PROFILE -Target $sourcePath
        Write-Output "PowerShell profile symlink created successfully."
    } catch {
        $script:errorLog += "Failed to setup PowerShell profile: $_"
    }
}

function Set-GitConfig {
    Write-Output "`nSetting up Git config..."
    try {
        $gitConfigPath = Join-Path -Path $HOME -ChildPath ".gitconfig"
        if (Test-Path $gitConfigPath) {
            Remove-Item $gitConfigPath -Force
        }

        $sourcePath = Join-Path -Path $HOME -ChildPath "dotfiles\Config\.gitconfig"
        New-Item -ItemType SymbolicLink -Path $gitConfigPath -Target $sourcePath
        Write-Output "Git config symlink created successfully."
    } catch {
        $script:errorLog += "Failed to setup Git config: $_"
    }
}

function Start-AdminContext {
    param (
        [Parameter(Mandatory)]
        [string]$ScriptBlock
    )

    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Output "Requesting administrative privileges..."
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptBlock))
        $process = Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encodedCommand" -Wait -PassThru
        
        if ($process.ExitCode -ne 0) {
            $script:errorLog += "Admin operation failed with exit code: $($process.ExitCode)"
        }
    } else {
        Invoke-Expression $ScriptBlock
    }
}

function Enable-UltimatePerformance {
    Write-Output "`nEnabling Ultimate Performance power plan..."
    $command = {
        # Check if Ultimate Performance plan exists
        $ultimatePlan = powercfg /list | Select-String "Ultimate Performance" | Select-String -NotMatch "Duplicate"
        
        # If plan doesn't exist, create it
        if (-not $ultimatePlan) {
            Write-Output "Creating Ultimate Performance power plan..."
            powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
            # Get the newly created plan
            $ultimatePlan = powercfg /list | Select-String "Ultimate Performance" | Select-String -NotMatch "Duplicate"
        }

        # Activate the plan
        if ($ultimatePlan) {
            $guid = [regex]::Match($ultimatePlan, '([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})').Groups[1].Value
            powercfg /setactive $guid
            Write-Output "Ultimate Performance power plan activated successfully."
        }
    }
    
    Start-AdminContext -ScriptBlock $command.ToString()
}

function Set-RecycleBinConfig {
    Write-Output "`nConfiguring Recycle Bin..."
    $command = {
        # Remove from desktop
        $desktopPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        $recycleBinGuid = "{645FF040-5081-101B-9F08-00AA002F954E}"
        if (-not (Test-Path $desktopPath)) {
            New-Item -Path $desktopPath -Force
        }
        Set-ItemProperty -Path $desktopPath -Name $recycleBinGuid -Value 1

        # Add to navigation pane
        $clsidPath = "HKCU:\SOFTWARE\Classes\CLSID\$recycleBinGuid"
        
        if (-not (Test-Path $clsidPath)) {
            New-Item -Path $clsidPath -Force
        }
        
        # Set required properties
        Set-ItemProperty -Path $clsidPath -Name "System.IsPinnedToNameSpaceTree" -Value 1 -Type DWord

        # Restart explorer to apply changes
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer
        
        Write-Output "Recycle Bin configuration updated successfully."
    }
    
    Start-AdminContext -ScriptBlock $command.ToString()
}

function Disable-BingSearch {
    Write-Output "`nDisabling Bing search in Start Menu..."
    $command = {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force
        }
        Set-ItemProperty -Path $path -Name "BingSearchEnabled" -Value 0
        Set-ItemProperty -Path $path -Name "CortanaConsent" -Value 0
        
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Process explorer
        
        Write-Output "Bing search disabled successfully."
    }
    
    Start-AdminContext -ScriptBlock $command.ToString()
}

function Set-SystemProductName {
    Write-Output "`nSetting system product name..."
    $command = {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force
        }
        Set-ItemProperty -Path $path -Name "Model" -Value "Sasindu's PC" -Type String
        
        Write-Output "System product name updated successfully."
    }
    
    Start-AdminContext -ScriptBlock $command.ToString()
}

function Show-ErrorSummary {
    if ($errorLog.Count -gt 0) {
        Write-Output "`n`nError Summary:"
        Write-Output "=============="
        foreach ($error in $errorLog) {
            Write-Output "- $error"
        }
    } else {
        Write-Output "`n`nSetup completed successfully with no errors!"
    }
}

# Main execution
Initialize-Environment
Install-Applications
Install-Dotfiles
Set-PowerShellProfile
Set-GitConfig
Enable-UltimatePerformance
Set-RecycleBinConfig
Disable-BingSearch
Set-SystemProductName
Show-ErrorSummary
