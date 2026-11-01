-- Rex does not watch this file. Apply changes with `rex config reload`.
-- Lua API: https://www.superlogical.com/rex/docs/reference/lua

rex.bind("cmd+d", "pane.split.auto")
rex.bind("cmd+h", "pane.focus.left")
rex.bind("cmd+j", "pane.focus.down")
rex.bind("cmd+k", "pane.focus.up")
rex.bind("cmd+l", "pane.focus.right")
rex.bind("cmd+shift+h", "pane.move.left")
rex.bind("cmd+shift+j", "pane.move.down")
rex.bind("cmd+shift+k", "pane.move.up")
rex.bind("cmd+shift+l", "pane.move.right")
rex.bind("cmd+shift+enter", "pane.zoom")
rex.bind("alt+shift+k", "pane.resize", { direction = "up" })
rex.bind("alt+shift+j", "pane.resize", { direction = "down" })
rex.bind("alt+shift+h", "pane.resize", { direction = "left" })
rex.bind("alt+shift+l", "pane.resize", { direction = "right" })
