-- █ █ ▄▀█ █▀█ █ ▄▀█ █▄▄ █   █▀▀ █▀
-- ▀▄▀ █▀█ █▀▄ █ █▀█ █▄█ █▄▄ ██▄ ▄█
--
-- Lua-порт variables.conf: общие пути и приложения.
-- Модуль возвращает таблицу, остальные модули подключают её через
--   local V = require("config.variables")

local home = os.getenv("HOME")

return {
    -- Path
    scrPath = home .. "/.local/bin",              -- default scripts path

    -- Apps
    term       = "kitty",
    menu       = "rofi -show drun -show-icons",
    file       = "kitty -e yazi",
    browser    = "firefox",
    office     = "libreoffice",                   -- unused, kept for parity
    lockscreen = "hyprlock",
    code       = "kitty -e nvim",
    clipboard  = "clipman pick -t rofi",          -- unused, kept for parity

    -- Main modifier
    mainMod = "SUPER",
}