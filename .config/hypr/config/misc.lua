-- █▀▄▀█ █ █▀ █▀▀
-- █ ▀ █ █ ▄█ █▄▄
--
-- Misc: miscellaneous, xwayland and ecosystem options.
-- Docs: https://wiki.hypr.land/configuring/core/variables/

hl.config({
	misc = {
		vrr = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
	},

	xwayland = {
		force_zero_scaling = true,
	},

	ecosystem = {
		no_update_news = true,
	},
})

-- render was commented out in the previous config:
-- hl.config({ render = { cm_fs_passthrough = 0 } })
