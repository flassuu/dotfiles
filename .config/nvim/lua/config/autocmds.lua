-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reload theme
local theme = require("theme.apply")

-- Autoread

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "checktime",
})

-- 1. гарантированный запуск после ВСЕГО
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      theme.start()
    end, 100)
  end,
})

-- 2. fallback (если UI дергает буферы)
vim.api.nvim_create_autocmd("BufWinEnter", {
  once = true,
  callback = function()
    theme.start()
  end,
})

-- 3. ручной reload
vim.api.nvim_create_user_command("ThemeReload", function()
  theme.reload()
end, {})
