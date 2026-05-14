# Television shell integration (Ctrl+R history, Ctrl+T smart autocomplete)
if status is-interactive; and command -q tv
    tv init fish | source
end
