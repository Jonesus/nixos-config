{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-nix
      vim-surround
      vim-commentary
      fzf-vim
    ];
    settings = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      ignorecase = true;
      smartcase = true;
      mouse = "a";
      undofile = true;
      undodir = [ "~/.local/state/vim/undo" ];
    };
    extraConfig = ''
      syntax on
      filetype plugin indent on
      set clipboard=unnamedplus
      set scrolloff=5
      set hlsearch
      nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
      nnoremap <C-p> :Files<CR>
      call mkdir(expand('~/.local/state/vim/undo'), 'p')
    '';
  };
}
