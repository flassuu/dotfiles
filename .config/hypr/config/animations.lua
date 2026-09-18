-- ▄▀█ █▄░█ █ █▀▄▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▀█ █░▀█ █ █░▀░█ █▀█ ░█░ █ █▄█ █░▀█
--
-- Lua-порт animations.conf + animations/animations-default.conf
-- https://wiki.hypr.land/configuring/core/animations/
--
-- credit https://github.com/prasanthrangan/hyprdots

hl.config({
    animations = {
        enabled = true,
    },
})

-- bezier-кривые из animations-default.conf
hl.curve("wind",   { type = "bezier", points = { { x = 0.05, y = 0.9 }, { x = 0.1, y = 1.05 } } })
hl.curve("winIn",  { type = "bezier", points = { { x = 0.1,  y = 1.1 }, { x = 0.1, y = 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { x = 0.3,  y = -0.3 }, { x = 0,   y = 1 } } })
hl.curve("liner",  { type = "bezier", points = { { x = 1,    y = 1 },    { x = 1,   y = 1 } } })

-- animation = leaf, enabled, speed, bezier, style
hl.animation({ leaf = "windows",          enabled = true, speed = 6,  bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 6,  bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 5,  bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 5,  bezier = "wind",   style = "slide" })
hl.animation({ leaf = "border",           enabled = true, speed = 1,  bezier = "liner" })
hl.animation({ leaf = "borderangle",      enabled = true, speed = 30, bezier = "liner",  style = "once" })
hl.animation({ leaf = "fade",             enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 5,  bezier = "wind" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5,  bezier = "wind",   style = "slidevert" })