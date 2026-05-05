# Aliases
Set-Alias vim nvim
Set-Alias open ii
Set-Alias cat bat

# Starship Prompt
$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
Invoke-Expression (&starship init powershell)
