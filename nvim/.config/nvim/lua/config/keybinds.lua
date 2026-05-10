vim.g.mapleader = " "

local keymap = vim.keymap

-- keymap.set("n", "<leader>n", vim.cmd.Ex)

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlight" })


