-- █ █▄ █ █▀▀ █   █ █ █▀▄ █▀▀
-- █ █ ▀█ █▄▄ █▄▄ █▄█ █▄▀ ██▄
--
-- Hyprland main config, Lua edition (Hyprland 0.55+)
-- Docs: https://wiki.hypr.land/configuring/
--
-- Модульная структура повторяет старый .conf пакет:
--   hyprland.lua        -> точка входа (этот файл)
--   config/animations   -> анимации/кривые (было animations.conf + animations-default.conf)
--   config/autostart    -> автозапуск (hyprland.start)
--   config/common       -> курсор/шрифты через gsettings
--   config/colors       -> цвета, генерируется matugen
--   config/env          -> переменные окружения
--   config/input        -> ввод/устройства/жесты
--   config/keybinds     -> клавиатурные бинды
--   config/layouts      -> dwindle
--   config/misc         -> misc/xwayland/ecosystem
--   config/monitors     -> мониторы
--   config/style        -> general/group/decoration
--   config/variables    -> пути и приложения
--   config/windowrules  -> правила окон (активные)
--   config/windowrulesold -> старые правила (НЕ подключается, как и windowrulesold.conf)

require("config.animations")
require("config.autostart")
require("config.common")
require("config.env")
require("config.input")
require("config.keybinds")
require("config.layouts")
require("config.misc")
require("config.monitors")
require("config.style")
require("config.variables")
require("config.windowrules")
-- require("config.windowrulesold") -- mirror старого windowrulesold.conf: не подключался и раньше