-- █▀▀ █░█ █▀█ █▀ █▀█ █▀█
-- █▄▄ █▄█ █▀▄ ▄█ █▄█ █▀▄
--
-- Lua-порт common.conf: курсор и шрифты (выполняются при старте сессии).

hl.on("hyprland.start", function()
    -- Cursor
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 18")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 18")

    -- Fonts
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-name 'Cantarell 10'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface document-font-name 'Cantarell 10'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaCove Nerd Font Mono 9'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface font-hinting 'full'")
end)