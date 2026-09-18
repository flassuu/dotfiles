-- ▄▀█ █ █ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█  █  █▄█ ▄█  █  █▀█ █▀▄  █
--
-- Lua-порт autostart.conf: процессы, стартующие с сессией.
-- https://wiki.hypr.land/configuring/core/autostart/

local V = require("config.variables")

hl.on("hyprland.start", function()
    -- scripts
    hl.exec_cmd(V.scrPath .. "/awww-watcher")          -- save current wallpaper as file to cache

    -- apps
    hl.exec_cmd("waybar")                              -- system bar
    hl.exec_cmd("awww-daemon")                         -- wallpaper daemon
    hl.exec_cmd("hypridle")                            -- idle daemon (hypridle.conf остаётся .conf)
    hl.exec_cmd("easyeffects")                         -- sound control

    hl.exec_cmd("wl-paste -t text --watch clipman store") -- clipboard manager
end)