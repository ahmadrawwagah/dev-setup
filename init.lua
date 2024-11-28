vim.opt.termguicolors = true
-- Bootstrap lazy.nvim
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {


		{ "catppuccin/nvim",         name = "catppuccin", priority = 1000 },

		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
				"3rd/image.nvim",  -- Optional image support in preview window: See `# Preview Mode` for more information
				{
					's1n7ax/nvim-window-picker',
					version = '2.*',
					config = function()
						require 'window-picker'.setup({
							filter_rules = {
								include_current_win = false,
								autoselect_one = true,
								-- filter using buffer options
								bo = {
									-- if the file type is one of following, the window will be ignored
									filetype = { 'neo-tree', "neo-tree-popup", "notify" },
									-- if the buffer type is one of following, the window will be ignored
									buftype = { 'terminal', "quickfix" },
								},
							},
						})
					end,
				},
			},
			config = function()
				-- If you want icons for diagnostic errors, you'll need to define them somewhere:
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
					-- sort_function = function (a,b)
					--       if a.type == b.type then
					--           return a.path > b.path
					--       else
					--           return a.type > b.type
					--       end
					--   end , -- this sorts files and directories descendantly
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
							-- expander config, needed for nesting files
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
							-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
							-- then these will never be used.
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
								-- Change type
								added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
								modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
								deleted   = "✖", -- this can only be used in the git_status source
								renamed   = "󰁕", -- this can only be used in the git_status source
								-- Status type
								untracked = "",
								ignored   = "",
								unstaged  = "󰄱",
								staged    = "",
								conflict  = "",
							}
						},
						-- If you don't want to use these columns, you can set `enabled = false` for each of them individually
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
					-- A list of functions, each representing a global custom command
					-- that will be available in all sources (if not overridden in `opts[source_name].commands`)
					-- see `:h neo-tree-custom-commands-global`
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
							-- Read `# Preview Mode` for more information
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
								-- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
								-- some commands may take optional config options, see `:h neo-tree-mappings` for details
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
							-- ["c"] = {
							--  "copy",
							--  config = {
							--    show_path = "none" -- "none", "relative", "absolute"
							--  }
							--}
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
							--               -- the current file is changed while the tree is open.
							leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
						},
						group_empty_dirs = false, -- when true, empty folders will be grouped together
						hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
						-- in whatever position is specified in window.position
						-- "open_current",  -- netrw disabled, opening a directory opens within the
						-- window like netrw would, regardless of window.position
						-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
						use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
						-- instead of relying on nvim autocmd events.
						window = {
							mappings = {
								["<bs>"] = "navigate_up",
								["."] = "set_root",
								["H"] = "toggle_hidden",
								["/"] = "noop",
								["D"] = "fuzzy_finder_directory",
								["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
								-- ["D"] = "fuzzy_sorter_directory",
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
								-- ['<key>'] = function(state, scroll_padding) ... end,
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
					ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end
		},
		{ 'echasnovski/mini.nvim',   version = false },
		{ 'neovim/nvim-lspconfig' },
		{ 'hrsh7th/nvim-cmp' },
		{ 'hrsh7th/cmp-nvim-lsp' },
		{ 'junegunn/fzf' },
		{ 'junegunn/fzf.vim' },
		{ 'feline-nvim/feline.nvim' },
		{ 'akinsho/bufferline.nvim', version = "*",       dependencies = 'nvim-tree/nvim-web-devicons' },
		{ 'tpope/vim-fugitive' }
	},
	install = { colorscheme = { "habamax" } },
	checker = { enabled = true },
})


require('mini.pairs').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
-- NOTE: to make any of this work you need a language server.
-- If you don't know what that is, watch this 5 min video:
-- https://www.youtube.com/watch?v=LaS32vctfOY

-- Reserve a space in the gutter
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lspconfig_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
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

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- These are example language servers.
require('lspconfig').pylsp.setup({})
require('lspconfig').clangd.setup({})
require 'lspconfig'.lua_ls.setup {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT'
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME
					-- Depending on the usage, you might want to add additional paths here.
					-- "${3rd}/luv/library"
					-- "${3rd}/busted/library",
				}
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
				-- library = vim.api.nvim_get_runtime_file("", true)
			}
		})
	end,
	settings = {
		Lua = {}
	}
}


local cmp = require('cmp')

cmp.setup({
	sources = {
		{ name = 'nvim_lsp' },
	},
	snippet = {
		expand = function(args)
			-- You need Neovim v0.10 to use vim.snippet
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({}),
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
				text = "Nvim Tree",
				separator = true,
				text_align = "center",
			},
		},
	}
})



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
vim.opt.hlsearch = false
vim.opt.incsearch = true


vim.opt["tabstop"] = 4
vim.opt["shiftwidth"] = 4

vim.cmd([[nnoremap <C-n> :Neotree toggle<cr>]])
vim.cmd([[nnoremap <C-p> :Files<cr>]])
vim.cmd([[nnoremap <C-g> :RG<cr>]])
vim.cmd([[nnoremap <Tab> :bnext<cr>]])
vim.cmd([[nnoremap <S-Tab> :bprevious<cr>]])
vim.cmd([[nnoremap <C-c> :bp\|bd<cr>]])
vim.cmd([[nnoremap <C-s> :Neotree focus git_status<cr>]])


vim.cmd([[autocmd StdinReadPre * let s:std_in=1]])
