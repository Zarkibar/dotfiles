vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.number = true
opt.cursorline = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.autoindent = true

opt.wrap = false

opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.clipboard:append("unnamedplus") -- use system clipboard as default register


