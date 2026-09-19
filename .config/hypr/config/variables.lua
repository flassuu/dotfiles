-- █ █ ▄▀█ █▀█ █ ▄▀█ █▄▄ █  █▀▀ █▀
-- ▀▄▀ █▀█ █▀▄ █ █▀█ █▄█ █▄ ██▄ ▄█
--
-- Variables: shared paths and app defaults, loaded via require().
-- Docs: https://wiki.hypr.land/configuring/core/lua-utilities/

local home = os.getenv("HOME")

return {
	-- Path
	scrPath = home .. "/.local/bin", -- default scripts directory

	-- Apps
	term = "kitty",
	menu = "rofi -show drun -show-icons",
	file = "kitty -e yazi",
	browser = "firefox",
	office = "libreoffice", -- unused, kept for parity
	lockscreen = "hyprlock",
	code = "kitty -e nvim",
	clipboard = "quickshell ipc -p ~/.config/quickshell/clipboard call clipboardPanel toggle", -- unused, kept for parity

	-- Main modifier
	mainMod = "SUPER",
}
