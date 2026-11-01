# Matugen — как устроена смена цветов

Документация по системе генерации цветовых схем: источники цвета, шаблоны,
сборка тем Obsidian/Vesktop, правила правки и известные подводные камни.

Действует для `matugen 4.2.0` (`/usr/bin/matugen`), проверено 2026-11-01.

## 1. Идея в одном абзаце

Есть один источник цвета (готовая палитра из JSON, обои или один hex).
Matugen разворачивает его в набор шаблонов и записывает результат туда, где
приложение его читает: `~/.config/kitty/colors.conf`, `~/.config/waybar/colors.css`,
`.obsidian/themes/*/theme.css` и т.д. Ни одно из этих **выходных** мест руками не
правится: они перегенерируются при каждой смене темы или обоев.

## 2. Поток

```text
                         ┌─ themes/<name>.json        (готовая палитра)
источник цвета ──────────┼─ image <файл> / <обои>     (matugen вытаскивает цвета)
                         └─ color hex <#rrggbb>       (один акцентный цвет)
                 │
                 ▼
              matugen  (читает ~/.config/matugen/config.toml)
                 │
    ┌────────────┴─────────────┬──────────────┬─────────────┐
    ▼                          ▼              ▼             ▼
templates/colors.css     kitty.conf      hyprland.lua    ... (9 шаблонов)
    │                          │              │
    ▼                          ▼              ▼
~/.cache/matugen/colors.css   colors.conf   colors.lua        + post_hook
    │                                                            │
    ├─► obsidian-theme-assemble --all ─► .obsidian/themes/matu-*/theme.css
    └─► vesktop-theme-assemble --all  ─► ~/.config/vesktop/themes/*.theme.css
```

Ключевой момент: `colors.css` — это «универсальная палитра». Из неё собираются
темы, которые сами не умеют читать переменные Matugen (Obsidian, Vesktop).
Её `post_hook` и запускает оба сборщика.

## 3. Файлы и роли

| Путь | Роль | Правится руками |
|---|---|---|
| `~/.config/matugen/config.toml` | список шаблонов: input → output + `post_hook` | да |
| `~/.config/matugen/templates/*` | исходники шаблонов Matugen | **да, это источник правды** |
| `~/.config/matugen/themes/*.json` | 31 готовая палитра (Catppuccin, Nord, Gruvbox…) | можно добавлять |
| `~/.cache/matugen/colors.css` | отрендеренная палитра (`.theme-dark` + `--rgb-*`) | нет |
| `~/.cache/theme/current` | имя последней темы, выставленной `theme-switch` | нет |
| `~/.local/bin/theme-switch` | применение палитры из `themes/*.json` | да (не в git) |
| `~/.local/bin/rofi-theme-menu` | выбор темы через rofi | да (не в git) |
| `~/.local/bin/obsidian-theme-assemble` | палитра + шаблон → тема Obsidian | да (не в git) |
| `~/.local/bin/vesktop-theme-assemble` | палитра + шаблон → тема Vesktop | да (не в git) |
| `~/.local/bin/theme_assemble_lib.py` | общая библиотека сборщиков | да (не в git) |
| `~/.config/matugen/templates/obsidian-assemble/*.css` | «тело» тем Obsidian | **да** |
| `~/.config/matugen/templates/vesktop-assemble/*.css` | «тело» тем Vesktop | **да** |
| `~/Documents/Obsidian/kernel.v02/.obsidian/themes/matu-*/theme.css` | сгенерированные темы | **нет, перезаписываются** |
| `~/.config/vesktop/themes/matu-system24.theme.css` | сгенерированная тема | нет |
| `~/.config/{kitty,waybar,rofi,yazi,btop,cava}/…`, `~/.config/nvim/lua/theme/colors.lua`, `~/.config/hypr/config/colors.lua` | выходы остальных шаблонов | нет |

`~/.config/matugen` — симлинк на `~/.dotfiles/.config/matugen` (stow).
Скрипты в `~/.local/bin` в dotfiles **не** входят (см. §10).

## 4. Как это запускается

### 4.1 Готовая палитра

```bash
theme-switch list            # 31 имя из themes/*.json
theme-switch set catppuccin-mocha
theme-switch get             # читает ~/.cache/theme/current
```

`theme-switch set` выполняет `matugen json ~/.config/matugen/themes/<name>.json -c ~/.config/matugen/config.toml`
и пишет имя в `~/.cache/theme/current`.

Пункт меню: `rofi-theme-menu` → `theme-switch list` → rofi → `theme-switch set`.

### 4.2 Обои

`~/.config/quickshell/scripts/colors/switchwall.sh`:

```bash
matugen image <обои> --mode dark --type scheme-tonal-spot   # или color hex <#rrggbb>
```

`-c` не передаётся, поэтому используется тот же дефолтный
`~/.config/matugen/config.toml`. Дальше скрипт руками обновляет
`material_colors.scss` для quickshell и Qt-приложения.

### 4.3 Что происходит после matugen

Для каждого `[templates.*]` пишется `output_path`, затем по очереди выполняются
`post_hook`. Реально «тяжёлый» хук только у палитры:

```toml
[templates.colors]
input_path = "~/.config/matugen/templates/colors.css"
output_path = "~/.cache/matugen/colors.css"
post_hook = "obsidian-theme-assemble --all && vesktop-theme-assemble --all"
```

Остальные хуки перезапускают потребителей: `pkill -SIGUSR1 kitty`,
`hyprctl reload`, `pkill -SIGUSR2 waybar`, `pkill -USR1 cava`.

## 5. Шаблоны Matugen

Синтаксис: выражение `{{ путь.к.значению }}`, блоки `<* … *>`
(`if/else/endif`, `for … endfor`, `include "name"`), фильтры через `|`
(`lighten: 20.0`, `invert`), арифметика. Экранирование — `\{{ … }}`.

Доступные поля (одинаковы для всех источников, включая `image`):

```text
base.{background,foreground,cursor}
ui.{surface,surface2,surface3,border,inactive}
accent.{primary,secondary,tertiary}
state.{error,warning,success}
normal.{black,red,green,yellow,blue,magenta,cyan,white}
bright.{black,red,green,yellow,blue,magenta,cyan,white}
```

Модификаторы: `.hex` → `#1e1e2e`, `.rgb` → `rgb(30, 30, 46)`.
В этом репозитории везде используется `.hex`.

Для `matugen json <file>` структура берётся из самого JSON, поэтому
`templates/colors.css` пишет `{{ base.background.hex }}` — это `base.background.color`
из `themes/<name>.json`. Ключ `color` в JSON, место `hex` — в шаблоне.

Пример (`templates/colors.css`, фрагмент):

```css
.theme-dark {
  --background: {{ base.background.hex }};
  --primary: {{ accent.primary.hex }};
}
```

Палитра всегда рендерится в `.theme-dark` (тёмный вариант). Светлого варианта
в системе нет: `mode` в `switchwall.sh` влияет только на выбор оттенков.

## 6. Сборка тем Obsidian и Vesktop

### 6.1 Obsidian

```bash
obsidian-theme-assemble matu-termina   # одну
obsidian-theme-assemble --all          # все
```

Алгоритм (`~/.local/bin/obsidian-theme-assemble`):

1. читает `~/.cache/matugen/colors.css`;
2. `inject_extra` дописывает внутрь блока палитры два блока:
   - `--rgb-<ключ>: r, g, b` для каждого цвета (нужно шаблонам, которые
     используют `rgb(var(--rgb-x))`);
   - производные оттенки `--rgb-overlay2/overlay1/mantle/crust/lavender`
     (смеси foreground/background/primary, «как в Catppuccin»);
3. склеивает `шапка + палитра + "\n\n" + шаблон` и пишет в
   `~/Documents/Obsidian/kernel.v02/.obsidian/themes/<Имя>/theme.css`.

Соответствие имён — словарь `THEME_NAMES` в скрипте:

| шаблон | папка темы |
|---|---|
| `matu-termina-theme.css` | `.obsidian/themes/matu-termina/` |
| `matu-catppuccin-theme.css` | `.obsidian/themes/matu-catppuccin/` |
| `obsidian-theme.css` | `.obsidian/themes/matugen/` (шаблона нет, пропускается) |

Шаблон — это вторая половина файла: алиасы, маппинг переменных Obsidian и
стили. Палитру в шаблоне объявлять не нужно, она уже вставлена сверху.

Темы `termina` и `Catppuccin` в vault — сторонние, Matugen их не трогает.

### 6.2 Vesktop

```bash
vesktop-theme-assemble --all
```

Палитра переводится из `.theme-dark` в `:root` (у Discord нет темы-скоупа) и
вставляется в шаблон на место маркера:

```css
/* @palette */
```

Маркер обязателен: без него сборщик падает с ошибкой. Выход —
`~/.config/vesktop/themes/<name>.theme.css`.

## 7. Как правильно менять

Правило одно: **меняешь вид — меняй шаблон, не результат.**

| Задача | Где править | Как применить |
|---|---|---|
| Стиль элементов Obsidian | `templates/obsidian-assemble/matu-termina-theme.css` | `obsidian-theme-assemble --all` |
| Цвета/контраст всей системы | `themes/<name>.json` или новый `theme-switch set` | `theme-switch set <name>` |
| Набор цветов (какие поля вообще есть) | `templates/colors.css` | любая смена темы |
| Новое приложение | новый блок `[templates.x]` + файл шаблона | `matugen json …` |
| Тема Obsidian с нуля | новый `*-theme.css` + строка в `THEME_NAMES` | `obsidian-theme-assemble <name>` |
| Тема Vesktop | `vesktop-assemble/*.css` с `/* @palette */` | `vesktop-theme-assemble --all` |

Чего не делать:

- не править `~/.cache/matugen/colors.css`, `~/.config/*/colors.*`,
  `.obsidian/themes/*/theme.css` и `~/.config/vesktop/themes/*.theme.css` —
  всё это перезапишется;
- не убирать `/* @palette */` из Vesktop-шаблонов;
- не переносить палитру в тело Obsidian-шаблона: она вставится дважды;
- не менять `output_path` на путь вне репозитория, если нужна история.

Проверка «нет ли дрейфа» после правки шаблона:

```bash
obsidian-theme-assemble --all
cd ~/Documents/Obsidian/kernel.v02 && git status --short -- .obsidian/themes
# пусто = сгенерированное совпадает с закоммиченным
```

## 8. Рецепты

**Сменить палитру.** `theme-switch set nord` (или `rofi-theme-menu`). Затрагивает
kitty, waybar, hyprland, rofi, yazi, btop, cava, nvim, Obsidian, Vesktop.

**Покрутить колауты Obsidian.** В `matu-termina-theme.css`, секция
`/* --- Callouts --- */`: плотность фона — второй процент в
`color-mix(in srgb, var(--callout-color) 15%, var(--bg-4))`, рамка —
`--callout-border-opacity` (0.45 в покое, 0.7 на hover). Затем
`obsidian-theme-assemble --all`.

**Добавить палитру.** Положить `themes/<name>.json` в том же формате, что
остальные (`base/ui/accent/state/normal/bright`, в каждом `{"color": "#rrggbb"}`),
затем `theme-switch set <name>`.

**Добавить приложение.** В `config.toml`:

```toml
[templates.myapp]
input_path = "~/.config/matugen/templates/myapp.conf"
output_path = "~/.config/myapp/colors.conf"
post_hook = "pkill -USR1 myapp"
```

и шаблон с `{{ accent.primary.hex }}`.

**Добавить тему Obsidian.** Файл `templates/obsidian-assemble/<name>-theme.css`
(без палитры), строка `"<name>": "<FolderName>"` в `THEME_NAMES`,
`obsidian-theme-assemble <name>`.

## 9. Отладка

```bash
matugen json ~/.config/matugen/themes/catppuccin-mocha.json -v   # что и куда пишет
cat ~/.cache/matugen/colors.css | head -20                        # палитра отрендерилась?
ls -l --time-style=full-iso ~/.config/kitty/colors.conf           # mtime = время прогона
obsidian-theme-assemble --all                                     # пересобрать только Obsidian
theme-switch get                                                  # какая тема «в памяти»
```

Опечатка в пути поля не проходит молча: matugen падает с
`Error: ResolveError … Value does not exist in the context` и **не** пишет
выходной файл (проверено: `{{ base.nope.hex }}`). Поэтому если файл обновился, но
значения старые — проблема не в шаблоне, а в том, что matugen не запускался.

## 10. Подводные камни (найдено 2026-11-01)

1. **Сгенерированные темы Obsidian перезаписываются.** Реальная история: правка
   `theme.css` вручную (коммит `c1ecd1f`) прожила минуту — в 15:41 прогон
   matugen собрал тему из шаблона и вернул старый код. Правка перенесена в
   `templates/obsidian-assemble/matu-termina-theme.css` (dotfiles `ac8a001`).
2. **`.obsidian/` лежит в синкаемом vault.** Даже правка, сделанная не через
   Matugen, может уехать/приехать с другой машины. Темы Obsidian — производные
   файлы, их место в git, а не в ручной правке на каждом устройстве.
3. **CSS-API Obsidian изменился: `--callout-color` — это цвет, а не триплет.**
   Старая запись `rgba(var(--callout-color), .4)` невалидна, объявления молча
   отбрасываются (колауты без фона и рамки). Правильно —
   `color-mix(in srgb, var(--callout-color) 25%, transparent)`. То же с
   `--canvas-color-*`: им нужны цвета, а не `--color-*-rgb`.
4. **`--callout-blend-mode` наследует `--highlight-mix-blend-mode`** (в тёмной
   теме это `lighten`). Со своей заливкой это даёт выгоревший цвет, поэтому в
   шаблонах стоит `mix-blend-mode: normal` на `.callout`.
5. **`theme-switch get` врёт после смены обоев.** `switchwall.sh` не пишет
   `~/.cache/theme/current`, поэтому состояние отражает последний `theme-switch`,
   а не фактическую палитру с диска.
6. **Скрипты сборки не версионируются.** `theme-switch`, `rofi-theme-menu`,
   `obsidian-theme-assemble`, `vesktop-theme-assemble`, `theme_assemble_lib.py`
   живут только в `~/.local/bin` (в dotfiles их нет) — при переустановке они
   потеряются.
7. **Прогон matugen дёргает приложения**: `pkill -SIGUSR1 kitty`, `hyprctl reload`,
   `pkill -SIGUSR2 waybar`, `pkill -USR1 cava`. Для точечной проверки Obsidian
   достаточно `obsidian-theme-assemble --all`.
8. **Мёртвая запись в `THEME_NAMES`**: `"obsidian": "matugen"` — шаблона
   `obsidian-theme.css` нет, ветка никогда не срабатывает.

## 11. Чек-лист при смене темы

```bash
theme-switch list                       # выбрать
theme-switch set <name>
cat ~/.cache/matugen/colors.css | head  # палитра обновилась
cd ~/Documents/Obsidian/kernel.v02 && git status --short -- .obsidian/themes
# если появились изменения — это ожидаемо, закоммитить как есть
```

После правки шаблонов:

```bash
obsidian-theme-assemble --all
vesktop-theme-assemble --all
cd ~/.dotfiles && git diff --stat          # шаблоны
cd ~/Documents/Obsidian/kernel.v02 && git diff --stat -- .obsidian/themes
```
