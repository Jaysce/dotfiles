# Aliases
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
}
Set-Alias open Invoke-Item
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

# Starship Prompt
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
