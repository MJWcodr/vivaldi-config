return {
  -- Plugins will be added here accordingly.
  { "github/copilot.vim" },
  { "nvim-telescope/telescope-file-browser.nvim" },
	{ "projekt0n/github-nvim-theme" },
	{ "eightpigs/win_resize.nvim" }, -- Resize windows with vim
	{ "rhysd/vim-grammarous" }, -- Enable Grammar Checking
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "nvim-lualine/lualine.nvim"
	},
	{ "chrisbra/csv.vim" },
	{ "hashivim/vim-terraform" },
	{ "nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
	{
  'chomosuke/typst-preview.nvim',
  lazy = false, -- or ft = 'typst'
  version = '1.*',
  build = function() require 'typst-preview'.update() end,
	},
	{
  'kaarmu/typst.vim',
  ft = 'typst',
  lazy=false,
  },
	{
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
	},
	{
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Diary",
      }
    },

    -- see below for full list of options 👇
  },

	{
		'lewis6991/gitsigns.nvim'
	},
},
{        "Mofiqul/adwaita.nvim",
        lazy = false,
        priority = 1000,
    },
	{"nvim-tree/nvim-web-devicons"}, -- File Explorer Icons
	{ "nvim-tree/nvim-tree.lua" },
	{ "lambdalisue/suda.vim"  }, -- Sudo Save
	{ "neoclide/coc.nvim", branch = "release", build = "npm install"},
	{
  "ray-x/go.nvim",
  dependencies = {  -- optional packages
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("go").setup()
  end,
  event = {"CmdlineEnter"},
  ft = {"go", 'gomod'},
  build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
}
}
