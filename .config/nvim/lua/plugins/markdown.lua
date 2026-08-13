return {
  -- Markdown rendering plugin with toggle via API
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = false, -- Load immediately so API is available
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local render = require("render-markdown")

      -- Setup with rendering DISABLED by default (raw markdown)
      render.setup({
        enabled = false,
        render_modes = { "n", "i", "v", "V", "" },
        heading = {
          enabled = true,
          sign = false,
          icons = { "", "", "", "", "", "" },
        },
        code = {
          enabled = true,
          sign = false,
          above = " ",
        },
        quote = {
          enabled = true,
        },
        pipe_table = {
          enabled = true,
        },
      })

      -- Global toggle function accessible from keymap
      _G.ToggleMarkdownRender = function()
        local buf = vim.api.nvim_get_current_buf()

        if vim.bo[buf].filetype ~= "markdown" then
          vim.notify("Not a markdown file", vim.log.levels.WARN)
          return
        end

        -- Use the plugin's built-in toggle method
        local is_enabled = render.toggle(buf)
        local status = is_enabled and "ON (formatted)" or "OFF (raw)"
        vim.notify("Markdown rendering: " .. status, vim.log.levels.INFO)
      end

      -- Create user command for completeness
      vim.api.nvim_create_user_command("ToggleMarkdownRender", function()
        _G.ToggleMarkdownRender()
      end, {})
    end,
  },
}
