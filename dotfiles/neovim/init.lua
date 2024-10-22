-- Path: init.lua
-- set leader key to space
vim.g.mapleader = " "

-- install plugins
require("lazy-config") -- install lazy-config
require("coc") -- install coc
require('lualine').setup() -- install lualine

require('gitsigns').setup() -- install gitsigns

local wk = require("which-key")
wk.register(mappings, opts)

-- set tab width
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- set line numbers
vim.opt.number = true

-- set colorscheme to catppuccin
vim.cmd("colorscheme catppuccin-mocha") -- dark-theme
-- light theme

-- set relative line numbers
vim.opt.relativenumber = true

-- set cursorline
vim.opt.cursorline = true

-- change windows with arrow keys in normal mode
vim.api.nvim_set_keymap("n", "<up>", "<c-w><up>", { noremap = true })
vim.api.nvim_set_keymap("n", "<down>", "<c-w><down>", { noremap = true })
vim.api.nvim_set_keymap("n", "<left>", "<c-w><left>", { noremap = true })
vim.api.nvim_set_keymap("n", "<right>", "<c-w><right>", { noremap = true })

-- split windows with ctrl + arrow keys
vim.api.nvim_set_keymap("n", "<c-right>", ":vsplit<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<c-up>", ":split<cr>", { noremap = true })

vim.api.nvim_set_keymap("n", "<c-left>", ":vsplit<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<c-down>", ":split<cr>", { noremap = true })

-- configure nvim-tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

wk.register({
	t = {
		name = "File Explorer",
		t = { "<cmd>NvimTreeToggle<cr>", "Toggle" },
		r = { "<cmd>NvimTreeRefresh<cr>", "Refresh" },
		f = { "<cmd>NvimTreeFindFile<cr>", "Find File" },
	},

}, { prefix = "<leader>" })

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- require('go').setup()

-- autocmd for typst
vim.api.nvim_create_autocmd(
    {
        "BufNewFile",
        "BufRead",
    },
    {
        pattern = "*.typ",
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_option(buf, "filetype", "typst")
        end
    }
)

require 'typst-preview'.setup {
	dependencies_bin = {
    ['tinymist'] = "/etc/profiles/per-user/matthias/bin/tinymist",
    ['websocat'] = "/etc/profiles/per-user/matthias/bin/websocat",
  },
}
