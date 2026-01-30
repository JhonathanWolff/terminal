
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

require("config.lazy")
require("config.keybinds")
vim.cmd.colorscheme "catppuccin"
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("EnableTreesitterHighlighting", { clear = true }),
  desc = "Try to enable tree-sitter syntax highlighting",
  pattern = "*", -- run on *all* filetypes
  callback = function()
    pcall(function() vim.treesitter.start() end)
  end,
})

-- space indentation
vim.o.tabstop = 4         
vim.o.shiftwidth = 4     
vim.o.softtabstop = 4   
vim.o.expandtab = true 
vim.o.autoindent = true   

--vim.g.vimspector_enable_mappings = 'HUMAN'
