-- ▄▀█ █ █ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█  █  █▄█ ▄█  █  █▀█ █▀▄  █
--
-- Autostart: processes launched when the session starts.
-- Docs: https://wiki.hypr.land/configuring/core/autostart/

local V = require("config.variables")

hl.on("hyprland.start", function()
	-- scripts
	hl.exec_cmd(V.scrPath .. "/awww-watcher") -- save current wallpaper as cache

	-- apps
	hl.exec_cmd("waybar") -- system bar
	hl.exec_cmd("awww-daemon") -- wallpaper daemon
	hl.exec_cmd("hypridle") -- idle daemon (config stays in hypridle.conf)
	hl.exec_cmd("easyeffects") -- sound control

	hl.exec_cmd("bash -c 'command -v cliphist >/dev/null 2>&1 && wl-paste --watch cliphist store || true'") -- clipboard history: text + screenshots
	hl.exec_cmd("bash -c 'command -v quickshell >/dev/null 2>&1 && quickshell -n -d -p ~/.config/quickshell/clipboard || true'") -- clipboard panel (ALT+V)
	hl.exec_cmd("bash -c 'command -v ydotoold >/dev/null 2>&1 && ydotoold || true'") -- paste injection daemon (ydotool)
end)
