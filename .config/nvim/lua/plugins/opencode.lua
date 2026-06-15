return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>oc",
        function()
          local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
          if root then
            root = vim.fn.trim(root)
          else
            root = vim.fn.getcwd()
          end
          vim.cmd("vsplit | term cd " .. vim.fn.shellescape(root) .. " && opencode")
          vim.cmd("startinsert")
        end,
        desc = "Open opencode",
      },
    },
  },
}
