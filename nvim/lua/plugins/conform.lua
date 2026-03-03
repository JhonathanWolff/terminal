return
{
  'stevearc/conform.nvim',
  opts = {},
  config = function ()

        require("conform").setup({
          formatters_by_ft = {
            lua = { "stylua" },
            python = { "autopep8" },
            bash = {"shfmt"},
            sh = {"shfmt"},
            zsh = {"beautysh"}
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
          },
        })

        vim.keymap.set("n", "<leader>F", function() require("conform").format({ lsp_fallback = true }) end, { desc = "Format file" })

  end
}
