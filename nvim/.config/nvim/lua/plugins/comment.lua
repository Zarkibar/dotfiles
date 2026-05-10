return {
    {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
	    "JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
	    local comment = require("Comment")

	    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

	    comment.setup({
		pre_hook = ts_context_commentstring.create_pre_hook(),
	    })
	end,
    },
    {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
	    local todo_comments = require("todo-comments")

	    local keymap = vim.keymap

	    keymap.set("n", "]t", function()
		todo_comments.jump_next()
	    end, { desc = "Next todo comment" })

	    keymap.set("n", "[t]", function()
		todo_comments.jump_prev()
	    end, { desc = "Previous todo comment" })

	    todo_comments.setup()
	end,
    },
}
