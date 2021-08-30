local status, tabline = pcall(require, "tabline")
if (not status) then return end

tabline.setup {
    enable = true
}

