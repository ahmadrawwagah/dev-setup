vim.opt.termguicolors = true
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
require("lazy").setup({
	spec = {
		{ "catppuccin/nvim",                          name = "catppuccin", priority = 1000 },
		{ 'junegunn/fzf' },
		{ 'rust-lang/rust.vim' },
		{ 'nvim-telescope/telescope.nvim' },
		{ 'lewis6991/gitsigns.nvim' },
		{ 'echasnovski/mini.nvim', },
		{ 'nvim-lua/plenary.nvim' },
		{ 'nvim-tree/nvim-web-devicons' },
		{ 'MunifTanjim/nui.nvim' },
		{ 'neovim/nvim-lspconfig' },
		{ 'hrsh7th/nvim-cmp' },
		{ 'hrsh7th/cmp-nvim-lsp' },
		{ 'hrsh7th/cmp-path' },
		{ 'hrsh7th/cmp-buffer' },
		{ 'hrsh7th/cmp-cmdline' },
		{ 'feline-nvim/feline.nvim' },
		{ 'rcarriga/nvim-notify' },
		{ 'akinsho/bufferline.nvim' },
		{ 'soulis-1256/eagle.nvim' },
		{ 'tpope/vim-fugitive' },
		{ 'folke/noice.nvim' },
		{ 'dstein64/nvim-scrollview' },
		{ 'lukas-reineke/indent-blankline.nvim' },
		{ 'mfussenegger/nvim-dap' },
		{ 'nvim-neotest/nvim-nio' },
		{ 'rcarriga/nvim-dap-ui' },
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				{
					's1n7ax/nvim-window-picker',
					version = '2.*',
					config = function()
						require 'window-picker'.setup({
							filter_rules = {
								include_current_win = false,
								autoselect_one = true,
								bo = {
									filetype = { 'neo-tree', "neo-tree-popup", "notify" },
									buftype = { 'terminal', "quickfix" },
								},
							},
						})
					end,
				},
			},
			config = function()
				vim.fn.sign_define("DiagnosticSignError",
					{ text = " ", texthl = "DiagnosticSignError" })
				vim.fn.sign_define("DiagnosticSignWarn",
					{ text = " ", texthl = "DiagnosticSignWarn" })
				vim.fn.sign_define("DiagnosticSignInfo",
					{ text = " ", texthl = "DiagnosticSignInfo" })
				vim.fn.sign_define("DiagnosticSignHint",
					{ text = "󰌵", texthl = "DiagnosticSignHint" })

				require("neo-tree").setup({
					close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
					popup_border_style = "rounded",
					enable_git_status = true,
					enable_diagnostics = true,
					open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
					sort_case_insensitive = false,                      -- used when sorting files and directories in the tree
					sort_function = nil,                                -- use a custom function for sorting files and directories in the tree
					default_component_configs = {
						container = {
							enable_character_fade = true
						},
						indent = {
							indent_size = 2,
							padding = 1, -- extra padding on left hand side
							-- indent guides
							with_markers = true,
							indent_marker = "│",
							last_indent_marker = "└",
							highlight = "NeoTreeIndentMarker",
							with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
							expander_collapsed = "",
							expander_expanded = "",
							expander_highlight = "NeoTreeExpander",
						},
						icon = {
							folder_closed = "",
							folder_open = "",
							folder_empty = "󰜌",
							provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
								if node.type == "file" or node.type == "terminal" then
									local success, web_devicons = pcall(require, "nvim-web-devicons")
									local name = node.type == "terminal" and "terminal" or node.name
									if success then
										local devicon, hl = web_devicons.get_icon(name)
										icon.text = devicon or icon.text
										icon.highlight = hl or icon.highlight
									end
								end
							end,
							default = "*",
							highlight = "NeoTreeFileIcon"
						},
						modified = {
							symbol = "[+]",
							highlight = "NeoTreeModified",
						},
						name = {
							trailing_slash = false,
							use_git_status_colors = true,
							highlight = "NeoTreeFileName",
						},
						git_status = {
							symbols = {
								added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
								modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
								deleted   = "✖", -- this can only be used in the git_status source
								renamed   = "󰁕", -- this can only be used in the git_status source
								untracked = "",
								ignored   = "",
								unstaged  = "󰄱",
								staged    = "",
								conflict  = "",
							}
						},
						file_size = {
							enabled = true,
							required_width = 64, -- min width of window required to show this column
						},
						type = {
							enabled = true,
							required_width = 122, -- min width of window required to show this column
						},
						last_modified = {
							enabled = true,
							required_width = 88, -- min width of window required to show this column
						},
						created = {
							enabled = true,
							required_width = 110, -- min width of window required to show this column
						},
						symlink_target = {
							enabled = false,
						},
					},
					commands = {},
					window = {
						position = "left",
						width = 40,
						mapping_options = {
							noremap = true,
							nowait = true,
						},
						mappings = {
							["<space>"] = {
								"toggle_node",
								nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
							},
							["<2-LeftMouse>"] = "open",
							["<cr>"] = "open",
							["<esc>"] = "cancel", -- close preview or floating neo-tree window
							["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
							["l"] = "focus_preview",
							["S"] = "open_split",
							["s"] = "open_vsplit",
							-- ["S"] = "split_with_window_picker",
							-- ["s"] = "vsplit_with_window_picker",
							["t"] = "open_tabnew",
							--["<cr>"] = "open_drop",
							-- ["t"] = "open_tab_drop",
							["w"] = "open_with_window_picker",
							--["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
							["C"] = "close_node",
							-- ['C'] = 'close_all_subnodes',
							["z"] = "close_all_nodes",
							--["Z"] = "expand_all_nodes",
							["a"] = {
								"add",
								config = {
									show_path = "none" -- "none", "relative", "absolute"
								}
							},
							["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
							["d"] = "delete",
							["r"] = "rename",
							["y"] = "copy_to_clipboard",
							["x"] = "cut_to_clipboard",
							["p"] = "paste_from_clipboard",
							["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
							["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
							["q"] = "close_window",
							["R"] = "refresh",
							["?"] = "show_help",
							["<"] = "prev_source",
							[">"] = "next_source",
							["i"] = "show_file_details",
						}
					},
					nesting_rules = {},
					filesystem = {
						filtered_items = {
							visible = false, -- when true, they will just be displayed differently than normal items
							hide_dotfiles = true,
							hide_gitignored = true,
							hide_hidden = true, -- only works on Windows for hidden files/directories
							hide_by_name = {
								--"node_modules"
							},
							hide_by_pattern = { -- uses glob style patterns
								--"*.meta",
								--"*/src/*/tsconfig.json",
							},
							always_show = { -- remains visible even if other settings would normally hide it
								--".gitignored",
							},
							always_show_by_pattern = { -- uses glob style patterns
								--".env*",
							},
							never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
								--".DS_Store",
								--"thumbs.db"
							},
							never_show_by_pattern = { -- uses glob style patterns
								--".null-ls_*",
							},
						},
						follow_current_file = {
							enabled = false,  -- This will find and focus the file in the active buffer every time
							leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
						},
						group_empty_dirs = false, -- when true, empty folders will be grouped together
						hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
						use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
						window = {
							mappings = {
								["<bs>"] = "navigate_up",
								["."] = "set_root",
								["H"] = "toggle_hidden",
								["/"] = "noop",
								["D"] = "fuzzy_finder_directory",
								["#"] = "fuzzy_sorter",
								["f"] = "filter_on_submit",
								["<c-x>"] = "clear_filter",
								["[g"] = "prev_git_modified",
								["]g"] = "next_git_modified",
								["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
								["oc"] = { "order_by_created", nowait = false },
								["od"] = { "order_by_diagnostics", nowait = false },
								["og"] = { "order_by_git_status", nowait = false },
								["om"] = { "order_by_modified", nowait = false },
								["on"] = { "order_by_name", nowait = false },
								["os"] = { "order_by_size", nowait = false },
								["ot"] = { "order_by_type", nowait = false },
								-- ['<key>'] = function(state) ... end,
							},
							fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
								["<down>"] = "move_cursor_down",
								["<C-n>"] = "move_cursor_down",
								["<up>"] = "move_cursor_up",
								["<C-p>"] = "move_cursor_up",
							},
						},

						commands = {} -- Add a custom command or override a global one using the same function name
					},
					buffers = {
						follow_current_file = {
							enabled = true, -- This will find and focus the file in the active buffer every time
							--              -- the current file is changed while the tree is open.
							leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
						},
						group_empty_dirs = true, -- when true, empty folders will be grouped together
						show_unloaded = true,
						window = {
							mappings = {
								["bd"] = "buffer_delete",
								["<bs>"] = "navigate_up",
								["."] = "set_root",
								["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
								["oc"] = { "order_by_created", nowait = false },
								["od"] = { "order_by_diagnostics", nowait = false },
								["om"] = { "order_by_modified", nowait = false },
								["on"] = { "order_by_name", nowait = false },
								["os"] = { "order_by_size", nowait = false },
								["ot"] = { "order_by_type", nowait = false },
							}
						},
					},
					git_status = {
						window = {
							position = "float",
							mappings = {
								["A"]  = "git_add_all",
								["gu"] = "git_unstage_file",
								["ga"] = "git_add_file",
								["gr"] = "git_revert_file",
								["gc"] = "git_commit",
								["gp"] = "git_push",
								["gg"] = "git_commit_and_push",
								["o"]  = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
								["oc"] = { "order_by_created", nowait = false },
								["od"] = { "order_by_diagnostics", nowait = false },
								["om"] = { "order_by_modified", nowait = false },
								["on"] = { "order_by_name", nowait = false },
								["os"] = { "order_by_size", nowait = false },
								["ot"] = { "order_by_type", nowait = false },
							}
						}
					}
				})
			end
		},
		{
			'nvim-treesitter/nvim-treesitter',
			build = ":TSUpdate",
			config = function()
				local configs = require("nvim-treesitter.configs")

				configs.setup({
					ensure_installed = { "c", "cpp", "rust", "python", "go", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end
		},
		{
			"folke/trouble.nvim",
			opts = {}, -- for default options, refer to the configuration section for custom setup.
			cmd = "Trouble",
			keys = {
				{
					"<leader>xx",
					"<cmd>Trouble diagnostics toggle win.position=right win.size=0.25<cr>",
					desc = "Diagnostics (Trouble)",
				},
				{
					"<leader>xX",
					"<cmd>Trouble diagnostics toggle filter.buf=0 win.position=right win.size=0.25<cr>",
					desc = "Buffer Diagnostics (Trouble)",
				},
				{
					"<leader>cs",
					"<cmd>Trouble symbols toggle focus=true win.position=right win.size=0.25<cr>",
					desc = "Symbols (Trouble)",
				},
				{
					"<leader>cl",
					"<cmd>Trouble lsp toggle focus=true win.position=right win.size=0.25<cr>",
					desc = "LSP Definitions / references / ... (Trouble)",
				},
				{
					"<leader>xL",
					"<cmd>Trouble loclist toggle<cr>",
					desc = "Location List (Trouble)",
				},
				{
					"<leader>xQ",
					"<cmd>Trouble qflist toggle<cr>",
					desc = "Quickfix List (Trouble)",
				},
			},
		},

	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
})


require('mini.pairs').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
require('mini.surround').setup()
require('gitsigns').setup()
require("eagle").setup()
require("dapui").setup()

vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
		vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
		vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
		vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
		vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
		vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
		vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
		vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
		vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
		vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
	end,
})

local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			vim.snippet.expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },
	})
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' },
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pylsp.setup({
	capabilities = capabilities
})
require('lspconfig').clangd.setup({
	capabilities = capabilities
})
require 'lspconfig'.lua_ls.setup {
	capabilities = capabilities,
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				version = 'LuaJIT'
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME
				}
			}
		})
	end,
	settings = {
		Lua = {}
	}
}

local on_attach = function(bufnr)
	vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
end

require('lspconfig').rust_analyzer.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		["rust-analyzer"] = {
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true,
				},
			},
			procMacro = {
				enable = true
			},
		}
	}
})


local ctp_feline = require('catppuccin.groups.integrations.feline')

ctp_feline.setup()

require("feline").setup({
	components = ctp_feline.get(),
})
require("bufferline").setup({
	options = {
		offsets = {
			{
				filetype = "neo-tree",
				text = "Neo-Tree",
				separator = true,
				text_align = "center",
			},
		},
	}
})

require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true,   -- use a classic bottom cmdline for search
		command_palette = false, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false,     -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
})

require('scrollview').setup({
	excluded_filetypes = { 'nerdtree' },
	current_only = true,
	base = 'right',
	signs_on_startup = { 'diagnostics', 'search' },
	diagnostics_severities = { vim.diagnostic.severity.ERROR }
})

require("ibl").setup({
	scope = {
		enabled = false
	}

})
local actions = require("telescope.actions")
require('telescope').setup {
	extensions = {
		fzf = {
			fuzzy = true,          -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		}
	},
	defaults = {
		mappings = {
			i = {
				["<esc>"] = actions.close,
			},
		},
	},

}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

vim.opt.signcolumn = 'yes'
vim.o.mousemoveevent = true
vim.cmd.colorscheme "catppuccin"
vim.opt.number = true
vim.opt.expandtab = false
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.swapfile = false
vim.opt.cursorline = true
vim.opt.autoread = true
vim.opt.magic = true
vim.opt.shiftround = true
vim.opt.copyindent = true
vim.opt.ruler = true
vim.opt.compatible = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt["tabstop"] = 4
vim.opt["shiftwidth"] = 4
vim.opt["mouse"] = "a"

vim.cmd([[set clipboard=unnamedplus]])
vim.cmd([[nnoremap <C-n> <cmd>Neotree toggle<cr>]])
vim.cmd([[nnoremap <C-p> <cmd>Telescope find_files<cr>]])
vim.cmd([[nnoremap <C-g> <cmd>Telescope live_grep<cr>]])
vim.cmd([[nnoremap <Tab> <cmd>bnext<cr>]])
vim.cmd([[nnoremap <S-Tab> <cmd>bprevious<cr>]])
vim.cmd([[nnoremap <C-c> <cmd>bp\|bd<cr>]])
vim.cmd([[nnoremap <C-s> <cmd>Neotree focus git_status<cr>]])
vim.cmd([[nnoremap <leader>bl <cmd>Gitsigns blame<cr>]])
vim.cmd([[nnoremap <leader>Bl <cmd>>Gitsigns toggle_current_line_blame<cr>]])
vim.cmd([[autocmd StdinReadPre * let s:std_in=1]])
