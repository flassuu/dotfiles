return {
  "catgoose/nvim-colorizer.lua",
  event = "VeryLazy",
  opts = {
    filetypes = { "*" },
    options = {
      parsers = {
        css = true,
      },
      display = {
        mode = "background",
      },
    },
  },
  keys = {
    { "<leader>uC", "<cmd>ColorizerAttachToBuffer<cr>", desc = "Attach Colorizer" },
    { "<leader>uD", "<cmd>ColorizerDetachFromBuffer<cr>", desc = "Detach Colorizer" },
  },
  config = function(_, opts)
    require("colorizer").setup(opts)
    vim.cmd("ColorizerAttachToBuffer")
  end,
}
