-- █ █ █ █ █▄ █ █▀▄ █▀█ █ █ █   █▀█ █ █ █   █▀▀ █▀
-- ▀▄▀▄▀ █ █ ▀█ █▄▀ █▄█ ▀▄▀▄▀   █▀▄ █▄█ █▄▄ ██▄ ▄█
--
-- Lua-порт windowrulesold.conf.
-- ВАЖНО: как и старый windowrulesold.conf, этот модуль НЕ ПОДКЛЮЧАЕТСЯ
-- (в hyprland.lua он закомментирован). Перенесён для полноты архива —
-- подключите require("config.windowrulesold") в hyprland.lua, если захотите
-- вернуть «полупрозрачные окна и флоат-правила» из старого эксперимента.

-- Opacity (active/inactive)
hl.window_rule({ match = { class = "^(kitty)$" },                                    opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$" },                          opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(org.kde.ark)$" },                              opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(nwg-look)$" },                                 opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(qt5ct)$" },                                    opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(qt6ct)$" },                                    opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(kvantummanager)$" },                           opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" },               opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(blueman-manager)$" },                          opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(nm-applet)$" },                                opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" },                     opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1)$" },      opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(org.freedesktop.impl.portal.desktop.gtk)$" },  opacity = "0.8 0.7" })
hl.window_rule({ match = { class = "^(org.freedesktop.impl.portal.desktop.hyprland)$" }, opacity = "0.8 0.7" })

hl.window_rule({ match = { class = "^(com.ayugram.desktop)$" },                      opacity = "0.9 0.9" })

hl.window_rule({ match = { class = "^(com.github.rafostar.Clapper)$" },              opacity = "0.9 0.9" })
hl.window_rule({ match = { class = "^(com.github.tchx84.Flatseal)$" },               opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(hu.kramo.Cartridges)$" },                      opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" },                    opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(gnome-boxes)$" },                              opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(vesktop)$" },                                  opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(discord)$" },                                  opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(WebCord)$" },                                  opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(app.drey.Warp)$" },                            opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(yad)$" },                                      opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(Signal)$" },                                   opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(io.github.alainm23.planify)$" },               opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" },       opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(com.github.unrud.VideoDownloader)$" },         opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(io.gitlab.adhami3310.Impression)$" },          opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(io.missioncenter.MissionCenter)$" },           opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(io.github.flattool.Warehouse)$" },             opacity = "0.8 0.8" })

-- Float rules
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Progress Dialog — Dolphin)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.dolphin)$", title = "^(Copying — Dolphin)$" },          float = true })
hl.window_rule({ match = { title = "^(About Mozilla Firefox)$" },                                     float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },                 float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Library)$" },                            float = true })
hl.window_rule({ match = { class = "^(kitty)$",   title = "^(top)$" },                                float = true })
hl.window_rule({ match = { class = "^(kitty)$",   title = "^(btop)$" },                               float = true })
hl.window_rule({ match = { class = "^(kitty)$",   title = "^(htop)$" },                               float = true })
hl.window_rule({ match = { class = "^(vlc)$" },                                                       float = true })
hl.window_rule({ match = { class = "^(kvantummanager)$" },                                            float = true })
hl.window_rule({ match = { class = "^(qt5ct)$" },                                                     float = true })
hl.window_rule({ match = { class = "^(qt6ct)$" },                                                     float = true })
hl.window_rule({ match = { class = "^(nwg-look)$" },                                                  float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" },                                               float = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" },                                float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" },                                           float = true })
hl.window_rule({ match = { class = "^(nm-applet)$" },                                                 float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" },                                      float = true })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" },                 float = true })

hl.window_rule({ match = { class = "^(Signal)$" },                                                   float = true })
hl.window_rule({ match = { class = "^(com.github.rafostar.Clapper)$" },                               float = true })
hl.window_rule({ match = { class = "^(app.drey.Warp)$" },                                             float = true })
hl.window_rule({ match = { class = "^(net.davidotek.pupgui2)$" },                                     float = true })
hl.window_rule({ match = { class = "^(yad)$" },                                                       float = true })
hl.window_rule({ match = { class = "^(eog)$" },                                                       float = true })
hl.window_rule({ match = { class = "^(io.github.alainm23.planify)$" },                                float = true })
hl.window_rule({ match = { class = "^(io.gitlab.theevilskeleton.Upscaler)$" },                        float = true })
hl.window_rule({ match = { class = "^(com.github.unrud.VideoDownloader)$" },                           float = true })
hl.window_rule({ match = { class = "^(io.gitlab.adhami3310.Impression)$" },                            float = true })
hl.window_rule({ match = { class = "^(io.missioncenter.MissionCenter)$" },                             float = true })

-- Common modals
hl.window_rule({ match = { title = "^(Open)$" },                          float = true })
hl.window_rule({ match = { title = "^(Choose Files)$" },                  float = true })
hl.window_rule({ match = { title = "^(Save As)$" },                       float = true })
hl.window_rule({ match = { title = "^(Confirm to replace files)$" },      float = true })
hl.window_rule({ match = { title = "^(File Operation Progress)$" },       float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" },        float = true })

-- Per-app tweaks
hl.window_rule({ match = { class = "^(firefox)$" },                       opacity = "0.9 0.9" })
hl.window_rule({ match = { class = "^(kicad)$" },                         opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^([Ss]team)$" },                      opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(steamwebhelper)$" },                opacity = "0.7 0.7" })
hl.window_rule({ match = { class = "^(Spotify)$" },                       opacity = "0.7 0.7" })
hl.window_rule({ match = { class = "^(blender)$" },                       float = true }) -- в старом файле помечено «main window: tile», правило = float

-- KeePassXC
hl.window_rule({ match = { class = "^(org.keepassxc.KeePassXC)$", title = ".*KeePassXC.*" }, opacity = "0.8 0.8" })
hl.window_rule({ match = { class = "^(org.keepassxc.KeePassXC)$", title = ".*[Locked].*" }, float = true })
hl.window_rule({ match = { class = "^(org.keepassxc.KeePassXC)$", title = ".*[Locked].*" }, center = true })
hl.window_rule({ match = { class = "^(org.keepassxc.KeePassXC)$", title = ".*[Locked].*" }, size   = { 800, 500 } })

-- Obsidian
hl.window_rule({ match = { class = "^(obsidian)$" },                      opacity = "0.8 0.8" })

-- Layer rules (порт layerrulev2)
-- Прим.: «ignorezero» из hyprlang здесь = ignore_alpha = 0 (ближайший современный эквивалент)
hl.layer_rule({ match = { namespace = "rofi" },                    blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "notifications" },           blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-control-center" },   blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "logout_dialog" },           blur = true })