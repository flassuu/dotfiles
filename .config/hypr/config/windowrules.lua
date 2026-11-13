-- █ █ █ █ █▄ █ █▀▄ █▀█ █ █ █    █▀█ █ █ █  █▀▀ █▀
-- ▀▄▀▄▀ █ █ ▀█ █▄▀ █▄█ ▀▄▀▄▀    █▀▄ █▄█ █▄ ██▄ ▄█
--
-- Window rules: window and layer rules by class, title or namespace.
-- Docs: https://wiki.hypr.land/configuring/core/rules/window-rules/
--       https://wiki.hypr.land/configuring/core/rules/layer-rules/

hl.window_rule({
	name = "godot-only-game-float",
	match = {
		initial_title = "^Godot$",
		initial_class = "negative:^Godot$", -- float only the game window, not the editor
	},
	float = true,
	center = true,
})

-- Opening a file or link from another app (yazi, chat, mail, ...) should bring
-- the existing browser window into view and switch to its workspace. Scoped to
-- the browser so background apps cannot steal focus globally.
hl.window_rule({
	name = "firefox-focus-on-activate",
	match = { class = "firefox" },
	focus_on_activate = true,
})
