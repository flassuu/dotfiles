return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = false, -- Load immediately to handle Flutter projects correctly
    dependencies = {
      "nvim-lua/plenary.nvim", -- Common lua functions library
      "stevearc/dressing.nvim", -- Prettier UI for selection lists
    },
    config = function()
      require("flutter-tools").setup({
        flutter_path = "/opt/flutter/bin/flutter",
        lsp = {
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
          },
        },
        -- Debugger (DAP) settings
        debugger = {
          enabled = true, -- Enable debugging support
          register_configurations = function(_)
            -- Custom launch configuration for Dart/Flutter
            require("dap").configurations.dart = {
              {
                type = "dart",
                request = "launch",
                name = "Launch Flutter App",
                -- Replace these paths if your SDK is located elsewhere
                dartSdkPath = "/opt/flutter/bin/cache/dart-sdk/bin/dart",
                flutterSdkPath = "/opt/flutter/bin/flutter",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
              },
            }
          end,
        },
        -- Development Log settings
        dev_log = {
          enabled = true,
          open_cmd = "tabedit", -- Open the Flutter logs in a new tab
        },
      })

      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        pattern = { "*.dart" },
        callback = function()
          local lsp_utils = require("flutter-tools.lsp.utils")
          if not lsp_utils.get_dartls_client() then
            require("flutter-tools.lsp").attach()
          end
        end,
        desc = "Attach Dart LSP via flutter-tools",
      })
    end,
  },
}
