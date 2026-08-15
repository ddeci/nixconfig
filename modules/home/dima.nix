{ ... }:
{
  imports = [ ./neovim ];

  home = {
    username = "dima";
    homeDirectory = "/home/dima";
    stateVersion = "26.11";
  };

  programs.home-manager.enable = true;
}
