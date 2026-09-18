-- █▀▀ █▄ █ █ █ █ █▀▄ █▀█ █▄ █ █▄█ █▀▀ █▄ █ ▀█▀
-- ██▄ █ ▀█ ▀▄▀ █ █▀▄ █▄█ █ ▀█ █▀█ ██▄ █ ▀█  █
--
-- Lua-порт env.conf: переменные графического окружения.
-- https://wiki.hypr.land/configuring/core/environment-variables/

local home    = os.getenv("HOME")
local scrPath = home .. "/.local/bin"

hl.env("HYPRSHOT_DIR", home .. "/Pictures/Screenshots")
hl.env("PATH", os.getenv("PATH") .. ":" .. scrPath)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("GDK_SCALE", "1")

hl.env("GTK_THEME", "Adwaita-dark")