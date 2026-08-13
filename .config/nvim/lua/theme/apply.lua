local M = {}

local function hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

function M.apply()
  local ok, c = pcall(require, "theme.colors")
  if not ok then
    return false, c
  end

  vim.o.termguicolors = true
  vim.o.background = "dark"

  vim.cmd("highlight clear")
  vim.cmd("syntax reset")

  -- Main editor interface
  hl("Normal", { fg = c.base.foreground, bg = c.base.background }) -- Default text and background
  hl("NormalNC", { fg = c.base.foreground, bg = c.base.background }) -- Non-current window background
  hl("EndOfBuffer", { fg = c.base.background, bg = c.base.background }) -- Tildes at the end of the buffer
  hl("SignColumn", { bg = c.base.background }) -- Column for git signs and diagnostics
  hl("CursorLine", { bg = c.ui.surface2 }) -- Highlight the line under the cursor
  hl("CursorLineNr", { fg = c.accent.primary, bold = true }) -- Current line number
  hl("LineNr", { fg = c.ui.surface3 }) -- All other line numbers
  hl("Visual", { bg = c.ui.surface3 }) -- Selected text highlight
  hl("TabLine", { fg = c.base.foreground }) -- Цвет табов
  hl("TabLineSel", { fg = c.accent.primary }) -- Активный таб

  -- Windows and borders
  hl("WinSeparator", { fg = c.ui.border }) -- Split dividers
  hl("VertSplit", { fg = c.ui.border }) -- Vertical split dividers
  hl("FloatBorder", { fg = c.ui.border, bg = c.ui.surface }) -- Borders for floating windows
  hl("NormalFloat", { fg = c.base.foreground, bg = c.ui.surface }) -- Background for floating windows
  hl("Directory", { fg = c.state.success })

  -- Search and selection
  hl("Search", { fg = c.base.foreground, bg = c.ui.surface3 }) -- Search result highlight
  hl("IncSearch", { fg = c.base.background, bg = c.accent.primary, bold = true }) -- Active search result

  -- Menus (Pmenu)
  hl("Pmenu", { fg = c.base.foreground, bg = c.ui.surface }) -- Completion menu background
  hl("PmenuSel", { fg = c.base.background, bg = c.accent.primary }) -- Selected item in menu
  hl("PmenuSbar", { bg = c.ui.surface2 }) -- Menu scrollbar background
  hl("PmenuThumb", { bg = c.ui.border }) -- Menu scrollbar handle

  -- Dashboard (Main Menu) colors
  hl("SnacksDashboardKey", { fg = c.accent.primary }) -- Shortkey color (f, n, p, etc.)
  hl("SnacksDashboardDesc", { fg = c.base.foreground }) -- Description text color
  hl("SnacksDashboardIcon", { fg = c.accent.secondary }) -- Icon color
  hl("SnacksDashboardHeader", { fg = c.accent.primary }) -- Big "LAZYVIM" logo color
  hl("SnacksDashboardFooter", { fg = c.ui.surface3 }) -- Bottom stats color

  -- Syntax: Basic elements
  hl("Comment", { fg = c.ui.surface3, italic = true }) -- Code comments
  hl("Keyword", { fg = c.accent.primary }) -- Language keywords (if, return, etc)
  hl("Function", { fg = c.accent.secondary }) -- Function names
  hl("String", { fg = c.state.success }) -- Text strings
  hl("Identifier", { fg = c.accent.tertiary }) -- Variable names
  hl("Type", { fg = c.accent.secondary }) -- Data types

  -- Syntax: Brackets and delimiters
  hl("@punctuation.bracket", { fg = c.ui.surface3 }) -- Brackets (), [], {}
  hl("Delimiter", { fg = c.ui.surface3 }) -- Separators like commas
  hl("@constructor", { fg = c.ui.surface3 }) -- Table/Object constructors {}

  -- Indentation and scope (Snacks.nvim)
  hl("SnacksIndentScope", { fg = c.accent.primary }) -- Active indentation line
  hl("SnacksIndent", { fg = c.ui.surface2 }) -- Standard indentation lines

  -- Constants and built-ins
  hl("Constant", { fg = c.accent.primary }) -- General constant values
  hl("@constant.builtin", { fg = c.accent.primary }) -- Built-in values (nil, true, false)
  hl("@lsp.type.variable.lua", { fg = c.accent.tertiary }) -- Lua specific variables via LSP

  -- UI Notifications and diagnostics
  hl("DiagnosticError", { fg = c.state.error }) -- LSP Error icons/text
  hl("DiagnosticWarn", { fg = c.state.warning }) -- LSP Warning icons/text
  hl("DiagnosticInfo", { fg = c.accent.secondary }) -- LSP Info icons/text
  hl("DiagnosticHint", { fg = c.accent.tertiary }) -- LSP Hint icons/text
  hl("ErrorMsg", { fg = c.state.error }) -- Error messages
  hl("WarningMsg", { fg = c.state.warning }) -- Warning messages
  hl("MoreMsg", { fg = c.state.success }) -- Status messages

  -- Statusline (Lualine)
  hl("LualineNormalA", { fg = c.base.background, bg = c.accent.primary, bold = true }) -- Mode (NORMAL)
  hl("LualineNormalB", { fg = c.base.foreground, bg = c.ui.surface2 }) -- Git branch section
  hl("LualineNormalC", { fg = c.ui.inactive, bg = c.ui.surface }) -- Main path section
  hl("LualineNormalC_normal", { fg = c.base.foreground }) -- Main text in statusline
  hl("LualineNormalC_filetype_devicon", { fg = c.accent.secondary }) -- File icons
  hl("LualineNormalX", { fg = c.ui.inactive, bg = c.ui.surface }) -- LSP/Encoding section
  hl("LualineNormalY", { fg = c.base.foreground, bg = c.ui.surface2 }) -- Progress info
  hl("LualineNormalZ", { fg = c.base.background, bg = c.accent.primary }) -- Cursor position

  -- Force StatusLine to match editor background
  hl("StatusLine", { fg = c.base.foreground, bg = c.base.background })
  hl("StatusLineNC", { fg = c.ui.inactive, bg = c.base.background })

  -- Lualine sections (Seamless blending)
  hl("LualineNormalA", { fg = c.base.background, bg = c.accent.primary, bold = true })

  -- Use c.base.background for B, C, and X to remove the "gray bar" effect
  hl("LualineNormalB", { fg = c.base.foreground, bg = c.base.background })
  hl("LualineNormalC", { fg = c.ui.inactive, bg = c.base.background })
  hl("LualineNormalX", { fg = c.ui.inactive, bg = c.base.background })

  -- Right-side sections
  hl("LualineNormalY", { fg = c.base.foreground, bg = c.base.background })
  hl("LualineNormalZ", { fg = c.base.background, bg = c.accent.primary })

  -- Fixed Separators (Triangles)
  -- Background MUST be c.base.background to avoid gray edges
  hl("LualineTransitional_LualineNormalA_to_LualineNormalB", { fg = c.accent.primary, bg = c.base.background })
  hl("LualineTransitional_LualineNormalB_to_LualineNormalC", { fg = c.base.background, bg = c.base.background })
  hl("LualineTransitional_LualineNormalY_to_LualineNormalZ", { fg = c.base.background, bg = c.accent.primary })

  -- Brackets and structural symbols
  hl("@punctuation.bracket", { fg = c.ui.surface3 }) -- All brackets (), [], {}
  hl("Delimiter", { fg = c.ui.surface3 }) -- Delimiters like commas and semicolons
  hl("@constructor", { fg = c.ui.surface3 }) -- Lua table constructors and similar {}

  -- Indentation lines (Snacks.nvim)
  hl("SnacksIndentScope", { fg = c.accent.primary }) -- Active indent line (current scope)
  hl("SnacksIndent", { fg = c.ui.surface2 }) -- Inactive/base indent lines

  -- Built-in constants and language keywords
  hl("@lsp.type.variable.lua", { fg = c.accent.tertiary }) -- Lua specific LSP variables
  hl("@constant.builtin", { fg = c.accent.primary }) -- Built-in constants like nil, true, false
  hl("Constant", { fg = c.accent.primary }) -- General constants

  -- Lualine sections (Status line at the bottom)
  -- Mode section (e.g., NORMAL, INSERT)
  hl("LualineNormalA", { fg = c.base.background, bg = c.accent.primary, bold = true })
  -- Branch/Git and file info
  hl("LualineNormalB", { fg = c.base.foreground, bg = c.ui.surface2 })
  -- Middle section (main background and path)
  hl("LualineNormalC", { fg = c.ui.inactive, bg = c.ui.surface })

  -- Lualine separators (The triangles)
  hl("LualineTransitional_LualineNormalA_to_LualineNormalB", { fg = c.accent.primary, bg = c.ui.surface2 })
  hl("LualineTransitional_LualineNormalB_to_LualineNormalC", { fg = c.accent.primary, bg = c.ui.surface })

  -- Specific indicators in Lualine
  hl("LualineNormalC_normal", { fg = c.base.foreground }) -- Primary text in statusline
  hl("LualineNormalC_filetype_devicon", { fg = c.accent.secondary }) -- Filetype icons color

  -- Right-side Lualine sections
  hl("LualineNormalX", { fg = c.ui.inactive, bg = c.ui.surface }) -- Secondary info (LSP/encoding)
  hl("LualineNormalY", { fg = c.base.foreground, bg = c.ui.surface2 }) -- Progress percentage
  hl("LualineNormalZ", { fg = c.base.background, bg = c.accent.primary }) -- Cursor position (line:col)
  return true
end

local state = {
  poll = nil,
  last_sig = nil,
}

local function file_sig(stat)
  if not stat or not stat.mtime then
    return nil
  end

  return table.concat({
    tostring(stat.size or 0),
    tostring(stat.mtime.sec or 0),
    tostring(stat.mtime.nsec or 0),
  }, ":")
end

function M.reload()
  package.loaded["theme.colors"] = nil

  local ok, err = M.apply()
  if not ok then
    vim.notify("Theme reload failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.start()
  if state.poll then
    return
  end

  local theme_file = vim.fn.stdpath("config") .. "/lua/theme/colors.lua"
  local stat = (vim.uv or vim.loop).fs_stat(theme_file)
  if not stat then
    vim.notify("Theme file not found: " .. theme_file, vim.log.levels.WARN)
    return
  end

  state.last_sig = file_sig(stat)
  M.reload()

  local uv = vim.uv or vim.loop
  state.poll = uv.new_fs_poll()
  state.poll:start(theme_file, 1000, function(err, prev, curr)
    if err then
      return
    end

    local sig = file_sig(curr)
    if sig and sig ~= state.last_sig then
      state.last_sig = sig
      vim.schedule(M.reload)
    end
  end)
end

return M
