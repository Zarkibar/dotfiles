return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
      local configs = require("nvim-treesitter")
      configs.setup({
	  highlight = {
	      enable = true,
	  },
	  indent = { enable = true },
	  autotage = { enable = true },
      })
      configs.install({ 'lua', 'javascript', 'typescript', 'tsx', 'go' }):wait(300000)
  end
}

