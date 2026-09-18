-- █ █▄ █ █▀█ █ █ ▀█▀
-- █ █ ▀█ █▀▀ █▄█  █
--
-- Input: keyboard layout, mouse, touchpad and gestures.
-- Docs: https://wiki.hypr.land/configuring/core/config-options/#input
--       https://wiki.hypr.land/configuring/core/binds/gestures/

hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:win_space_toggle",

		follow_mouse = 1,

		sensitivity = 0.35,
		force_no_accel = false,

		touchpad = {
			natural_scroll = true,
		},
	},
})

-- Per-device
hl.device({
	name = "mosart-semi.-2.4g-input-device-mouse",
	sensitivity = -0.1,
})

-- Gestures (trackpad)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.gesture({ fingers = 4, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down", action = "float" })
hl.gesture({ fingers = 4, direction = "left", action = "move" })
hl.gesture({ fingers = 4, direction = "right", action = "move" })

hl.gesture({ fingers = 4, direction = "swipe", mods = "SUPER", action = "resize" })
