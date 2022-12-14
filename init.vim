" source  ~/.config/nvim/init.vim
" echo stdpath('config')
" Directorio de plugins
" echo esto funciona perfect
"
let $OHS = "/home/cesarguzmanlopez/.bash_vim/"
set runtimepath^=$OHS/Config_Vim

let mapleader = "/"

source $OHS/Config_Vim/Default.vim
source $OHS/Config_Vim/Plugins.vim
source $OHS/Config_Vim/Aparience.vim
"source $OHS/Config_Vim/NerdTree.vim
source $OHS/Config_Vim/FZF.vim
source $OHS/Config_Vim/Coc.vim
source $OHS/Config_Vim/AutoCompletePairs.vim

source $OHS/Config_Vim/Functions_Java.vim
source $OHS/Config_Vim/Functions_C.vim

source $OHS/Config_Vim/keybindingsCoc.vim
source $OHS/Config_Vim/KeyBindingsFunctions.vim
source $OHS/Config_Vim/KeyBindings.vim

if exists("g:loaded_vimballPlugin") 
    function LoadNVIMAllPlugin()
"        so $MYVIMRC
    endfunction
    let g:loaded_vimballPlugin = 1
    call timer_start(100, {-> execute("call LoadNVIMAllPlugin()")})
endif

luafile $OHS/Config_Vim/tree.lua

