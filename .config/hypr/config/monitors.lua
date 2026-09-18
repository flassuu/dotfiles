-- █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
-- █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█
--
-- Monitors: outputs, resolution, position and scaling.
-- Docs: https://wiki.hypr.land/configuring/core/monitors/

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x1000",
    scale    = 1.5,
})
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@180",
    position = "1920x0",
    scale    = 1,
})