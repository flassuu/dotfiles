-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })

local map = vim.keymap.set

-- Flutter specific mappings
-- Start the application
map("n", "<leader>fr", "<cmd>FlutterRun<cr>", { desc = "Flutter: Run App" })

-- Reload the app (Hot Reload is usually auto on save, this is Hot Restart)
map("n", "<leader>fR", "<cmd>FlutterRestart<cr>", { desc = "Flutter: Hot Restart" })

-- Stop the application
map("n", "<leader>fq", "<cmd>FlutterQuit<cr>", { desc = "Flutter: Quit/Stop" })

-- Open device selector
map("n", "<leader>fd", "<cmd>FlutterDevices<cr>", { desc = "Flutter: Select Device" })

-- Open emulator selector
-- map("n", "<leader>fe", "<cmd>FlutterEmulators<cr>", { desc = "Flutter: Select Emulator" })

-- View development logs
map("n", "<leader>fl", "<cmd>FlutterLog<cr>", { desc = "Flutter: View Logs" })

-- Toggle markdown rendering
map("n", "<leader>mp", function()
  if _G.ToggleMarkdownRender then
    _G.ToggleMarkdownRender()
  else
    vim.notify("render-markdown not ready", vim.log.levels.ERROR)
  end
end, { desc = "Toggle Markdown Render" })
