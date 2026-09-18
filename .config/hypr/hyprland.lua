-- █ █ █▄█ █▀█ █▀█ █  ▄▀█ █▄ █ █▀▄
-- █▀█  █  █▀▀ █▀▄ █▄ █▀█ █ ▀█ █▄▀
--
-- Hyprland: entry point that loads every config module.
-- Docs: https://wiki.hypr.land/configuring/
--
-- Modules:
--   config/animations   -> animation curves and transitions
--   config/autostart    -> processes started with the session
--   config/common       -> cursor and fonts applied on session start
--   config/colors       -> matugen-generated color palette
--   config/env          -> environment variables
--   config/input        -> input devices and gestures
--   config/keybinds     -> keybindings and dispatcher actions
--   config/layouts      -> dwindle layout options
--   config/misc         -> misc, xwayland and ecosystem options
--   config/monitors     -> outputs, resolution and scaling
--   config/style        -> general, group and decoration settings
--   config/variables    -> shared paths and defaults
--   config/windowrules  -> window and layer rules

require("config.animations")
require("config.autostart")
require("config.common")
require("config.env")
require("config.input")
require("config.keybinds")
require("config.layouts")
require("config.misc")
require("config.monitors")
require("config.style")
require("config.variables")
require("config.windowrules")
