

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

require("config.lazy")
require("config.keybinds")



vim.cmd.colorscheme "catppuccin"
vim.opt.clipboard = "unnamedplus"


-- space indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.autoindent = true


-- remove tab winbar
vim.opt.showtabline = 0


-- Dap
--require("config.daps.python")


--auto CMD
require("autocmds.autocmd")

-- extra lsp config
require("config.lsp_configs")
