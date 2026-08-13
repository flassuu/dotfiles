return {
  -- LazyGit: A powerful terminal UI for git inside Neovim
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      -- Open LazyGit UI with <leader>gg
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },
  -- Octo: Edit GitHub issues and PRs like regular buffers
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- Initializing octo.nvim with default settings
      require("octo").setup()
    end,
  },
}
