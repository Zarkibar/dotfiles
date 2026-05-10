return {
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPre", "BufNewFile" },
    build = ':TSUpdate',
    dependencies = {
	"windwp/nvim-ts-autotag",
    },
    config = function()
	local configs = require("nvim-treesitter")
	configs.setup({
	    highlight = {
		enable = true,
	    },
	    indent = { enable = true },
	    autotage = { enable = true },
	})
	configs.install({ 
	    'lua', 
	    'javascript', 
	    'typescript', 
	    'tsx', 
	    'go', 
	    "yaml",
	    "html",
	    "css",
	    "bash",
	    "dockerfile",
	    "gitignore",
	    "c"
	})
    end
}

