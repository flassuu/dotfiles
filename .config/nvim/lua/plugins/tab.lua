return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "hide", "fallback" },
      },

      -- 1. Disable automatic bracket insertion and snippet expansion
      completion = {
        accept = {
          auto_brackets = {
            enabled = false, -- Stops auto-adding () and placeholder text
          },
        },
      },

      -- Keep other sources but explicitly remove 'snippets'
      sources = {
        default = { "lsp", "path", "buffer" }, -- Removed "snippets" source
      },
    },
  },
}
