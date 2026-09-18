-- ▄▀█ █ █ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░
--
-- Autostart: processes launched when the session starts.
-- Docs: https://wiki.hypr.land/configuring/core/autostart/

local V = require("config.variables")

hl.on("hyprland.start", function()
    -- scripts
    hl.exec_cmd(V.scrPath .. "/awww-watcher")          -- save current wallpaper as cache

    -- apps
    hl.exec_cmd("waybar")                              -- system bar
    hl.exec_cmd("awww-daemon")                         -- wallpaper daemon
    hl.exec_cmd("hypridle")                            -- idle daemon (config stays in hypridle.conf)
    hl.exec_cmd("easyeffects")                         -- sound control

    hl.exec_cmd("wl-paste -t text --watch clipman store") -- clipboard manager
end)