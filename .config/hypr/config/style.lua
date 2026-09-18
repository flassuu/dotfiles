-- █▀ ▀█▀ █▄█ █   █▀▀
-- ▄█  █   █  █▄▄ ██▄
--
-- Lua-порт style.conf: внешний вид (general/group/decoration).

local Colors = require("config.colors")

hl.config({
    general = {
        gaps_in         = 2,
        gaps_out        = 4,
        border_size     = 1,
        col = {
            active_border   = Colors.primary,   -- gradient: можно и { colors = {...}, angle = 45 }
            inactive_border = Colors.inactive,
        },
        layout          = "dwindle",
        resize_on_border = true,
    },

    group = {
        col = {
            border_active         = Colors.primary,
            border_inactive       = Colors.inactive,
            border_locked_active  = Colors.primary,
            border_locked_inactive = Colors.inactive,
        },
    },

    decoration = {
        rounding    = 6,
        dim_special = 0.5,

        blur = {
            enabled           = true,
            special           = true,   -- expensive, но было включено в старом конфиге
            size              = 2,
            passes            = 5,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
        },

        shadow = {
            enabled = false,
        },
    },
})