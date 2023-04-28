﻿local api = vim.api

vim.opt.list = true
vim.opt.listchars:append "space: "
vim.opt.termguicolors = true
require("tokyonight").setup(
  {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "storm", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day", -- The theme is used when the background is set to light
    transparent = true, -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
      functions = { italic = true },
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "transparent", -- style for sidebars, see below
      floats = "transparent", -- style for floating windows
    },
    sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
    day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = true, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false, -- dims inactive windows
    lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold

    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    ---@param colors ColorScheme
    on_colors = function(colors) end,

    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors) end,
  })
local ok, _ = pcall(vim.cmd, 'colorscheme tokyonight')


vim.cmd('hi Comment guifg=#ee88da')
vim.cmd('highlight Comment gui=italic')
vim.cmd('highlight Constant gui=bold')
--vim.cmd('highlight Identifier gui=bold')
-- char = '▏',
vim.opt.laststatus =3

require('lualine').setup {
  options = {
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = false,
    globalstatus =true,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'}, 
    lualine_y = { 'g:coc_status', 'location'},
    lualine_z = {'progress'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {},
  theme = 'tokyonight'
}
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("IndentBlanklineBigFile", {}),
    pattern = "*",
    callback = function()
        if vim.api.nvim_buf_line_count(0) > 3000 then
            require("indent_blankline.commands").disable()
        end
    end,
})


require("indent_blankline").setup( { 
  space_char_blankline = " ",
  indent_blankline_filetype_exclude = {"startify","dashboard", "help", "packer"},
  --  show_current_context_start = true,
  char_list = {'', '▏',  '|', '¦', '┆', '┊'},

  indent_blankline_context_patterns = {
        "^for", "^if", "^object", "^table", "^while", "arguments", "block",
        "catch_clause", "class", "else_clause", "function", "if_statement",
        "import_statement", "jsx_element", "jsx_element",
        "jsx_self_closing_element", "method", "operation_type", "return",
        "try_statement", "type", "while_statement", "with_statement",
        "jsx_element", "jsx_self_closing_element", "jsx_fragment", "public"
    }
})
