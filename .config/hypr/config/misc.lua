-- █▀▄▀█ █ █▀ █▀▀
-- █ ▀ █ █ ▄█ █▄▄
--
-- Lua-порт misc.conf: прочие настройки.

hl.config({
    misc = {
        vrr                         = 0,
        disable_hyprland_logo       = true,
        disable_splash_rendering    = true,
        force_default_wallpaper     = 0,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    ecosystem = {
        no_update_news = true,
    },
})

-- render был закомментирован в старом конфиге:
-- hl.config({ render = { cm_fs_passthrough = 0 } })