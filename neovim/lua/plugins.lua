vim.cmd([[packadd packer.nvim]])
pcall(require, "impatient")
return require("packer").startup(function(use)
	use("Pocco81/auto-save.nvim")
	use("akaron/vim-markdown-fold")
	use("akinsho/toggleterm.nvim")
	use("alec-gibson/nvim-tetris")
	use("b0o/incline.nvim")
	use("chrisbra/NrrwRgn")
	use("ethanholz/nvim-lastplace")
	use("folke/tokyonight.nvim")
	use("folke/which-key.nvim")
	use("github/copilot.vim")
	use("junegunn/fzf.vim")
	use("kdheepak/lazygit.nvim")
	use("kylechui/nvim-surround")
	use("lervag/vimtex")
	use("lewis6991/gitsigns.nvim")
	use("lewis6991/impatient.nvim")
	use("lukas-reineke/indent-blankline.nvim")
	use("majutsushi/tagbar")
	use("mboughaba/i3config.vim")
	use("mfussenegger/nvim-treehopper")
	use("mhinz/vim-startify")
	use("neovim/nvim-lspconfig")
	use("numToStr/Comment.nvim")
	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")
	use("nvim-tree/nvim-tree.lua")
	use("nvim-tree/nvim-web-devicons")
	use("nvim-treesitter/nvim-treesitter-textobjects")
	use("phaazon/hop.nvim")
	use("puremourning/vimspector")
	use("rafamadriz/friendly-snippets")
	--use("rcarriga/nvim-notify")
	use("ryanoasis/vim-devicons")
	use("sheerun/vim-polyglot")
	use("sindrets/winshift.nvim")
	use("skywind3000/asyncrun.vim")
	use("tmsvg/pear-tree")
	use("tpope/vim-eunuch")
	use("tpope/vim-fugitive")
	use("tpope/vim-repeat")
	use("tpope/vim-rhubarb")
	use("tpope/vim-sensible")
	use("voldikss/vim-translator")
	use("w0rp/ale")
	use("wbthomason/packer.nvim")
	use({"junegunn/fzf", run = ":call fzf#install()" })
	use({"mhinz/vim-signify", tag = "legacy" })
	use({"neoclide/coc.nvim", branch = "release" })
	use({"nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
	use({"nvim-treesitter/nvim-treesitter", run = ":TSInstall all", config = "" })
end)
