-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- For matugen theme
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Set the leader key to space for easier combinations
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Indentation rules (Dart/Flutter)
opt.shiftwidth = 2 -- Number of spaces for each step of indent
opt.tabstop = 2 -- Number of spaces a <Tab> counts for
opt.expandtab = true -- Convert tabs to spaces
opt.smartindent = true -- Insert indents automatically

-- UI and Experience
opt.number = true -- Show line numbers
opt.relativenumber = true -- Use relative numbers for quick vertical jumping
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.cursorline = true -- Highlight the current line
opt.scrolloff = 10 -- Keep at least 10 lines above/below the cursor
opt.signcolumn = "yes" -- Always show the sign column (prevents UI flickering)

-- Search behavior
opt.ignorecase = true -- Ignore case in search patterns
opt.smartcase = true -- Do not ignore case if the search contains uppercase
