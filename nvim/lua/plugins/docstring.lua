return {
"heavenshell/vim-pydocstring",
build = "pip install doq",
ft = "python",
config = function()
  vim.g.pydocstring_formatter = "google"
  vim.g.pydocstring_doq_path = vim.fn.exepath("doq")
end,

}
