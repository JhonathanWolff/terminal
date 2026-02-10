vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.api.nvim_set_keymap("x", "p", "pgvy", { noremap = true, silent = true })

-- comment line
vim.api.nvim_set_keymap(
	"x",
	"<C-k>",
	":lua require('Comment.api').locked('toggle.linewise')(vim.fn.visualmode())<CR>",
	{ noremap = true, silent = true }
)

-- navegacao
vim.api.nvim_set_keymap("n", "<S-Tab>", ":bprev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Tab>", ":bnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("i", "jk", "<esc>", { noremap = true })
--vim.api.nvim_set_keymap("n", "<leader>qq", ":q!<CR>", { noremap = true })

--buffer
vim.api.nvim_set_keymap("n", "<leader>bc", ":bd<CR>", { noremap = true, desc = "Close current Buffer" })
vim.api.nvim_set_keymap(
	"n",
	"<leader>ba",
	": %bd | e# | bd#<CR>",
	{ noremap = true, desc = "Close all buffers except this one" }
)

--editor
vim.keymap.set("n", "|", ":vsplit<CR>", { noremap = true })

-- move selection copy
vim.api.nvim_set_keymap("x", ">", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("x", "<", "<gv", { noremap = true, silent = true })

-- comand line
vim.api.nvim_set_keymap("n", "zs", ":w<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>", ":q<CR>", { noremap = true })

-- LSP
vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { desc = "Format File" })

--TELESCOPE
--vim.api.nvim_set_keymap("n", "ga", ":Telescope lsp_incoming_calls<CR>", { noremap = false, silent = true })
vim.api.nvim_set_keymap("v", "<leader>fc", "y<ESC>:Telescope grep_string default_text=<C-R>0<cr>", { noremap = false })

-- move windows
vim.api.nvim_set_keymap("n", "<C-k>", ":wincmd k<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":wincmd j<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-h>", ":wincmd h<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", ":wincmd l<CR>", { silent = true })



--LSP
vim.api.nvim_set_keymap('n', '<space>se', '<cmd>lua vim.diagnostic.open_float()<CR>', {noremap=true, silent=true})


--Lens 
vim.api.nvim_set_keymap("n","<leader>lt",":ErrorLensToggle<CR>",{noremap=true,silent=true,desc="Toggle Error Lens"})


--docstring generator
--
vim.api.nvim_set_keymap("n","<leader>md","<Plug>(pydocstring)",{noremap=true,silent=true,desc="Make Docstring Google Style"})
vim.api.nvim_set_keymap("v","<leader>md","<Plug>(pydocstring)",{noremap=true,silent=true,desc="Make Docstring Google Style"})



-- quick fix
vim.keymap.set("n", "<leader>qq", function()
  require("quicker").toggle()
end, {
  desc = "Toggle quickfix",
})
vim.keymap.set("n", "<leader>ql", function()
  require("quicker").toggle({ loclist = true })
end, {
  desc = "Toggle loclist",
})
