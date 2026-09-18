-- █ █ █ █ █▄░█ █▀▄ █▀█ █ █ █    █▀█ █ █ █ █▀▀ █▀
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀    █▀▄ █▄█ █▄▄ ██▄ ▄█
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
    float  = true,
    center = true,
})