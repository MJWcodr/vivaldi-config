-- Path: init.lua
-- set leader key to space
vim.g.mapleader = " "

-- install plugins
require("lazy-config") -- install lazy-config
require("coc") -- install coc
require('lualine').setup() -- install lualine
require('leap').create_default_mappings()

local wk = require("which-key")

require('gitsigns').setup() -- install gitsigns

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

-- configure nvim-tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()

wk.add({
	-- File Explorer
	{"<leader>t", group = "File Explorer"},
	{"<leader>tt", "<cmd>NvimTreeToggle<cr>", desc = "Toggle"},
	{"<leader>tr", "<cmd>NvimTreeRefresh<cr>", desc = "Refresh"},
	{"<leader>tf", "<cmd>NvimTreeFindFile<cr>", desc = "Find File"},

	-- Buffer Navigation
	{"", group = "Buffer Navigation"},
	{"<S-Tab>", "<cmd>BufferPrevious<cr>", desc = "Previous Buffer"},
	{"<Tab>", "<cmd>BufferNext<cr>", desc = "Next Buffer"},
	{"<leader>c", "<cmd>BufferClose<cr>", desc = "Close Buffer"},
	{"<leader>o", "<cmd>BufferCloseAllButCurrent<cr>", desc = "Close All But Current Buffer"},

	-- Window Navigation
	{"<left>", "<C-w>h", desc = "Move to the window to the left"},
	{"<down>", "<C-w>j", desc = "Move to the window below"},
	{"<up>", "<C-w>k", desc = "Move to the window above"},
	{"<right>", "<C-w>l", desc = "Move to the window to the right"},
	-- Split Windows with ctrl + arrow keys
	{"<c-right>", "<cmd>vsplit<cr>", desc = "Split window vertically"},
	{"<c-up>", "<cmd>split<cr>", desc = "Split window horizontally"},
	{"<c-left>", "<cmd>vsplit<cr>", desc = "Split window vertically"},
	{"<c-down>", "<cmd>split<cr>", desc = "Split window horizontally"},

})

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
