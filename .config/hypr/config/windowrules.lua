-- █ █ █ █ █▄ █ █▀▄ █▀█ █ █ █   █▀█ █ █ █   █▀▀ █▀
-- ▀▄▀▄▀ █ █ ▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- Lua-порт windowrules.conf (активные правила окон).
-- https://wiki.hypr.land/configuring/core/rules/window-rules/

hl.window_rule({
    name = "godot-only-game-float",
    match = {
        initial_title = "^Godot$",
        initial_class = "negative:^Godot$", -- float только игровое окно, не редактор
    },
    float  = true,
    center = true,
})