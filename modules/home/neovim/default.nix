{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      blink-cmp
      gitsigns-nvim
      hardtime-nvim
      nvim-lspconfig
      oil-nvim
      quicker-nvim
      smart-splits-nvim
      snacks-nvim
      vague-nvim
      vim-fugitive
      (nvim-treesitter.withPlugins (parsers: [
        parsers.c
        parsers.cpp
        parsers.css
        parsers.html
        parsers.javascript
        parsers.json
        parsers.lua
        parsers.markdown
        parsers.markdown_inline
        parsers.rust
        parsers.tsx
        parsers.typescript
      ]))
    ];

    initLua = builtins.readFile ./init.lua;
  };

  home.packages = [ pkgs.fzf ];
}
