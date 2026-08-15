-- =====================================================================
-- OPTIONS
-- =====================================================================
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- =====================================================================
-- PLUGIN SETUP
-- =====================================================================

-- Snacks
local snacks = require("snacks")
if not vim.g.snacks_did_setup then
	snacks.setup({
		bigfile = { enabled = true },
		notifier = { enabled = true, top_down = true, style = "compact" },
		picker = {
			enabled = true,
			layout = "custom",
			layouts = {
				custom = {
					layout = {
						box = "vertical",
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.4,
						border = "none",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{
							box = "horizontal",
							{ win = "list", title = " {title} {live} {flags}", border = "rounded" },
							{ win = "preview", title = "{preview}", width = 0.6, border = "rounded" },
						},
						{ win = "input", height = 1, border = "top" },
					},
				},
			},
			sources = {
				gh_issues = {},
				gh_pr = {},
				gh_diff = {},
				smart = {},
				grep = {},
			},
			win = {
				input = {
					keys = {
						["p"] = { "focus_preview", mode = { "n", "x" } },
					},
				},
			},
		},
	})
	vim.g.snacks_did_setup = true
end

-- Blink.cmp
require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust" },
	keymap = {
		preset = "default",
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
	},
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = {
			border = "rounded",
			draw = {
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			},
		},
		documentation = { auto_show = true, window = { border = "rounded" } },
	},
	signature = { enabled = true, window = { border = "rounded" } },
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
})

-- Oil
require("oil").setup()

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add          = { text = '│' },
		change       = { text = '│' },
		delete       = { text = '_' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	current_line_blame = false,
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local function map(mode, lhs, rhs, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		map('n', ']c', function()
			if vim.wo.diff then return ']c' end
			vim.schedule(function() gs.next_hunk() end)
			return '<Ignore>'
		end)

		map('n', '[c', function()
			if vim.wo.diff then return '[c' end
			vim.schedule(function() gs.prev_hunk() end)
			return '<Ignore>'
		end)
	end
})

-- Quicker
require("quicker").setup()

-- Treesitter
require("nvim-treesitter").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

-- Smart-splits
require("smart-splits").setup({
	at_edge = "stop",
	multiplexer_integration = nil,
})

-- Hardtime
require("hardtime").setup({
	enabled = false,
	disable_mouse = false,
	restricted_keys = {
		["h"] = { "n", "x" },
		["j"] = { "n", "x" },
		["k"] = { "n", "x" },
		["l"] = { "n", "x" },
		["-"] = {},
		["+"] = {},
	},
	hint = true,
	max_count = 4,
	disabled_filetypes = { "qf", "netrw", "lazy", "mason", "oil" },
})

-- =====================================================================
-- KEYMAPS
-- =====================================================================
-- f=files, b=buffers, g=git, l=lsp, x=diagnostics, u=ui

local map = vim.keymap.set

-- Basic
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>o', ':update<CR>:source %<CR>')
map('n', '<Esc>', ':nohlsearch<CR>')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Windows
map('n', '<C-h>', require('smart-splits').move_cursor_left)
map('n', '<C-j>', require('smart-splits').move_cursor_down)
map('n', '<C-k>', require('smart-splits').move_cursor_up)
map('n', '<C-l>', require('smart-splits').move_cursor_right)
map('n', '<A-h>', require('smart-splits').resize_left)
map('n', '<A-j>', require('smart-splits').resize_down)
map('n', '<A-k>', require('smart-splits').resize_up)
map('n', '<A-l>', require('smart-splits').resize_right)
map('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
map('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
map('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
map('n', '<leader><leader>l', require('smart-splits').swap_buf_right)

-- Files
map('n', '<leader>ff', function() snacks.picker.files() end)
map('n', '<leader>fr', function() snacks.picker.recent() end)
map('n', '<leader>fg', function() snacks.picker.git_files() end)
map('n', '-', ':Oil<CR>')

-- Buffers
map('n', '<leader>bb', function() snacks.picker.buffers() end)
map('n', '<leader>bd', ':bdelete<CR>')
map('n', '<leader>bn', ':bnext<CR>')
map('n', '<leader>bp', ':bprevious<CR>')

-- Search
map('n', '<leader>/', function() snacks.picker.grep() end)
map('n', '<leader>sw', function() snacks.picker.grep_word() end)
map('n', '<leader>sh', function() snacks.picker.help() end)
map('n', '<leader>sk', function() snacks.picker.keymaps() end)

-- Git
map('n', '<leader>gs', ':Git<CR>')
map('n', '<leader>gc', ':Git commit<CR>')
map('n', '<leader>gp', ':Git push<CR>')
map('n', '<leader>gl', ':Git log<CR>')
map('n', '<leader>gd', ':Gvdiffsplit<CR>')
map('n', '<leader>gw', ':Gwrite<CR>')
map('n', '<leader>ghs', ':Gitsigns stage_hunk<CR>')
map('n', '<leader>ghu', ':Gitsigns undo_stage_hunk<CR>')
map('n', '<leader>ghp', ':Gitsigns preview_hunk<CR>')
map('n', '<leader>ghr', ':Gitsigns reset_hunk<CR>')
map('n', '<leader>ghS', ':Gitsigns stage_buffer<CR>')
map('n', '<leader>ghR', ':Gitsigns reset_buffer<CR>')
map('n', '<leader>gb', ':Gitsigns toggle_current_line_blame<CR>')
map('n', '<leader>gB', ':Git blame<CR>')

-- LSP
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'gi', vim.lsp.buf.implementation)
map('n', 'gt', vim.lsp.buf.type_definition)
map('n', 'gr', vim.lsp.buf.references)
map('n', 'K', vim.lsp.buf.hover)
map('n', '<leader>lk', vim.lsp.buf.signature_help)
map('n', '<leader>la', vim.lsp.buf.code_action)
map('n', '<leader>lr', vim.lsp.buf.rename)
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', '<leader>ls', function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.notify('No LSP clients attached', vim.log.levels.WARN)
		return
	end

	vim.print(vim.tbl_map(function(client)
		return { name = client.name, root_dir = client.root_dir }
	end, clients))
end)
map('n', '<leader>lR', ':LspRestart<CR>')

-- Diagnostics
map('n', ']d', vim.diagnostic.goto_next)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', '<leader>xd', vim.diagnostic.open_float)
map('n', '<leader>xl', vim.diagnostic.setloclist)
map('n', '<leader>xq', vim.diagnostic.setqflist)
map('n', '<leader>xx', ':copen<CR>')
map('n', '<leader>xc', ':cclose<CR>')
map('n', ']q', ':cnext<CR>')
map('n', '[q', ':cprev<CR>')

-- UI
map('n', '<leader>uw', ':set wrap!<CR>')
map('n', '<leader>uh', ':Hardtime toggle<CR>')

-- =====================================================================
-- LSP CONFIG
-- =====================================================================
vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' },
			diagnostics = { globals = { 'vim', 'require' } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
})

-- Language-server binaries come from each project's Nix dev shell.
vim.lsp.enable({ 'clangd', 'lua_ls', 'rust_analyzer', 'ts_ls' })

-- =====================================================================
-- AUTOCOMMANDS
-- =====================================================================
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("help_vsplit", { clear = true }),
	pattern = "help",
	command = "wincmd L",
})

vim.api.nvim_create_autocmd("VimResized", {
	group = vim.api.nvim_create_augroup("auto_resize", { clear = true }),
	command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", { clear = true }),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

vim.api.nvim_create_autocmd("BufRead", {
	group = vim.api.nvim_create_augroup("dotenv_ft", { clear = true }),
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
	group = vim.api.nvim_create_augroup("active_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = true
	end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = vim.api.nvim_create_augroup("inactive_cursorline", { clear = true }),
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- =====================================================================
-- COLORSCHEME
-- =====================================================================
require("vague").setup({ transparent = true })
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
