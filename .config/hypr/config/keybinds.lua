-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄ █ █▀▄ █▀
-- █ █ ██▄  █  █▄█ █ █ ▀█ █▄▀ ▄█
--
-- Keybinds: keyboard shortcuts and dispatcher actions.
-- Docs: https://wiki.hypr.land/configuring/core/binds/
--       https://wiki.hypr.land/configuring/core/dispatchers/

local V = require("config.variables")
local mainMod = V.mainMod -- SUPER

-- Window/Session actions
hl.bind(mainMod .. " + Q", hl.dsp.window.close()) -- close focused window
hl.bind("ALT + F4", hl.dsp.window.close()) -- close focused window
hl.bind(mainMod .. " + Delete", hl.dsp.exit()) -- quit hyprland session
hl.bind(mainMod .. " + F", hl.dsp.window.float()) -- toggle floating (default action "toggle")
hl.bind(mainMod .. " + G", hl.dsp.group.toggle()) -- toggle grouping
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen()) -- toggle fullscreen

-- Application shortcuts
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(V.term)) -- terminal emulator
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(V.file)) -- file manager
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(V.browser)) -- web browser
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(V.code)) -- code editor
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(V.term .. " -e yazi")) -- yazi
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(V.term .. " -e btop")) -- resource monitor

-- Rofi menus
hl.bind("ALT + Space", hl.dsp.exec_cmd(V.menu)) -- rofi drun
hl.bind("ALT + R", hl.dsp.exec_cmd(V.scrPath .. "/rofi-app-menu")) -- apps menu script

-- Fn keys: volume control (locked + repeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pamixer --default-source -t"), { locked = true, repeating = true })

-- Brightness control
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })

-- Config editor (XF86Tools)
hl.bind("XF86Tools", hl.dsp.exec_cmd(V.scrPath .. "/rofi-configbrowser-menu"), { locked = true, repeating = true })

-- Screenshot / screen capture
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(V.scrPath .. "/screenshot p"))
hl.bind("Print", hl.dsp.exec_cmd(V.scrPath .. "/screenshot pf"))
hl.bind("ALT + Print", hl.dsp.exec_cmd(V.scrPath .. "/screenshot pc"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(V.scrPath .. "/screenshot am"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(V.scrPath .. "/screenshot aw"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(V.scrPath .. "/screenshot sw"))

-- Custom scripts
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(V.lockscreen)) -- lock screen

-- Move/Change window focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces
for i = 1, 10 do
	local key = i % 10 -- 10 -> "0"
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end

-- Switch to a relative workspace
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))

-- First empty workspace
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

-- Resize windows (repeating)
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move focused window to a workspace
for i = 1, 10 do
	local key = i % 10 -- 10 -> "0"
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move focused window to a relative workspace
hl.bind(mainMod .. " + CTRL + ALT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + left", hl.dsp.window.move({ workspace = "r-1" }))

-- Move active window around the current workspace:
-- floating -> move by delta, tiled -> swap with neighbour in direction.
-- Same shell pipeline as in the previous config (repeating + description).
local MOVE_ACTIVE =
	'grep -q "true" <<< "$(hyprctl activewindow -j | jq -r .floating)" && hyprctl dispatch \'hl.dsp.window.move({ x = %d, y = %d, relative = true })\' || hyprctl dispatch \'hl.dsp.window.move({ direction = \"%s\" })\''
hl.bind(
	mainMod .. " + SHIFT + CTRL + left",
	hl.dsp.exec_cmd(string.format(MOVE_ACTIVE, -30, 0, "left")),
	{ repeating = true, description = "Move activewindow left" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + right",
	hl.dsp.exec_cmd(string.format(MOVE_ACTIVE, 30, 0, "right")),
	{ repeating = true, description = "Move activewindow right" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + up",
	hl.dsp.exec_cmd(string.format(MOVE_ACTIVE, 0, -30, "up")),
	{ repeating = true, description = "Move activewindow up" }
)
hl.bind(
	mainMod .. " + SHIFT + CTRL + down",
	hl.dsp.exec_cmd(string.format(MOVE_ACTIVE, 0, 30, "down")),
	{ repeating = true, description = "Move activewindow down" }
)

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/Resize focused window with the mouse (mouse flag)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:", follow = false }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special()) -- default scratchpad

-- Move focused window to a workspace silently
for i = 1, 10 do
	local key = i % 10 -- 10 -> "0"
	hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
