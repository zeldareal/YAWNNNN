-- ~/.config/nvim/init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 200
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true

-- Plugin setup
require("lazy").setup({
	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",
			})
			vim.cmd([[colorscheme tokyonight]])
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"nixd",
					"rust_analyzer",
					"pyright",
					"clangd",
					"jdtls",
					"ts_ls",
				},
			})

			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Setup each LSP
			local servers = { "lua_ls", "nixd", "rust_analyzer", "pyright", "clangd", "jdtls", "ts_ls" }
			for _, lsp in ipairs(servers) do
				lspconfig[lsp].setup({
					capabilities = capabilities,
				})
			end
		end,
	},

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				},
			})
		end,
	},

	-- Mini plugins
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.pairs").setup()
			require("mini.comment").setup()
			require("mini.ai").setup()
		end,
	},

	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				window = {
					width = 30,
					position = "left",
				},
			})
			vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
		end,
	},

	-- Oil.nvim
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				view_options = {
					show_hidden = true,
				},
			})
			vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Open parent directory" })
		end,
	},

	-- Harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Harpoon add file" })
			vim.keymap.set("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Harpoon quick menu" })
			vim.keymap.set("n", "<leader>1", function()
				harpoon:list():select(1)
			end, { desc = "Harpoon file 1" })
			vim.keymap.set("n", "<leader>2", function()
				harpoon:list():select(2)
			end, { desc = "Harpoon file 2" })
			vim.keymap.set("n", "<leader>3", function()
				harpoon:list():select(3)
			end, { desc = "Harpoon file 3" })
			vim.keymap.set("n", "<leader>4", function()
				harpoon:list():select(4)
			end, { desc = "Harpoon file 4" })
		end,
	},

	-- Illuminate
	{
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				under_cursor = true,
				filetypes_denylist = {
					"neo-tree",
					"alpha",
					"toggleterm",
				},
			})
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				direction = "float",
				float_opts = {
					border = "curved",
					width = 120,
					height = 30,
				},
				open_mapping = [[<C-\>]],
			})

			-- Lazygit integration
			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				direction = "float",
				hidden = true,
				float_opts = {
					border = "curved",
				},
				on_open = function(term)
					vim.cmd("startinsert!")
				end,
			})

			function _lazygit_toggle()
				lazygit:toggle()
			end

			vim.keymap.set("n", "<leader>lg", _lazygit_toggle, { desc = "Lazygit" })
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
				},
			})
			require("telescope").load_extension("fzf")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
			vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Search in current buffer" })
		end,
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "" },
					topdelete = { text = "" },
					changedelete = { text = "▎" },
				},
			})
		end,
	},

	-- Which-key
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				delay = 100,
			})
		end,
	},

	-- Trouble
	{ "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

	-- Flash
	{ "folke/flash.nvim" },

	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 500,
				},
				formatters_by_ft = {
					lua = { "stylua" },
					nix = { "nixfmt" },
				},
			})
		end,
	},

	-- Linting
	{
		"mfussenegger/nvim-lint",
		config = function()
			require("lint").linters_by_ft = {
				lua = { "luacheck" },
				python = { "ruff" },
				c = { "cppcheck" },
				cpp = { "cppcheck" },
				java = { "checkstyle" },
				javascript = { "eslint" },
				typescript = { "eslint" },
				-- nix doesn't have great linter support in nvim-lint, nixd LSP handles it
			}

			-- Auto-lint on save and text changed
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "lua", "nix", "rust", "python", "c", "java", "typescript", "javascript" },
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = { theme = "auto" },
			})
		end,
	},

	{
		"akinsho/bufferline.nvim",
		config = function()
			require("bufferline").setup({
				options = {
					diagnostics = "nvim_lsp",
				},
			})
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("ibl").setup({
				scope = { enabled = true },
			})
		end,
	},

	-- Alpha dashboard
	{
		"goolord/alpha-nvim",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = {
				"                                                     ",
				"  ███████╗███████╗██╗     ██████╗  █████╗ ██╗   ██╗██╗███╗   ███╗ ",
				"  ╚══███╔╝██╔════╝██║     ██╔══██╗██╔══██╗██║   ██║██║████╗ ████║ ",
				"    ███╔╝ █████╗  ██║     ██║  ██║███████║██║   ██║██║██╔████╔██║ ",
				"   ███╔╝  ██╔══╝  ██║     ██║  ██║██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
				"  ███████╗███████╗███████╗██████╔╝██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
				"  ╚══════╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
				"                                                     ",
				"                 // yet another nvim config //          ",
			}

			alpha.setup(dashboard.opts)
		end,
	},

	{ "nvim-tree/nvim-web-devicons" },

	-- Noice
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},

	-- Notify
	{ "rcarriga/nvim-notify" },

	-- Persistence
	{ "folke/persistence.nvim", config = true },
})
