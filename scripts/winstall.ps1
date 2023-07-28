# Make sure winget is installed first from the MS Store

$tui =
"curl",
"sudo",
"jq",
"git",
"gh",
"neovim",
"starship",
"delta",
"FiraCode"

$gui = 
"Microsoft.PowerShell",
"AgileBits.1Password",
"Spotify.Spotify",
"GitHub.GitHubDesktop",
"Discord.Discord",
"LukiLabs.Craft",
"Microsoft.VisualStudioCode",
"Valve.Steam",
"Microsoft.PowerToys",
"xanderfrangos.twinkletray"

Set-Location

Write-Output "Installing scoop..."
Invoke-RestMethod get.scoop.sh | Invoke-Expression
scoop bucket add nerd-fonts
scoop bucket add extras

Write-Output "Installing scoop apps..."
for ($i = 0; $i -lt $tui.Count; $i++) {
    scoop install $tui[$i]
}

Write-Output "Cloning dotfiles..."
git clone https://github.com/Jaysce/dotfiles.git

Write-Output "Symlinking..."
cmd /c mklink /d %homepath%\.config\powershell %homepath%\dotfiles\Config\powershell
cmd /c mklink %homepath%\.gitconfig %homepath%\dotfiles\Config\.gitconfig

Write-Output "Updating PowerShell Profile..."
Add-Content -Path "$Profile.CurrentUserCurrentHost" -Value ". $env:USERPROFILE\.config\powershell\user_profile.ps1"

Write-Output "Installing GUI Apps..."
for ($i = 0; $i -lt $gui.Count; $i++) {
    winget install -e --id $gui[$i]
}

Write-Output "Setting System Product Name..."
Set-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name "Model" -Value "Sasindu's PC" -Type String