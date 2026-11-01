{ ... }:
{
  imports = [
    ./herdr.nix
    ./kagi-search.nix
    ./neovim
    ./shell
  ];

  home = {
    username = "dima";
    homeDirectory = "/home/dima";
    stateVersion = "26.11";
  };

  programs.home-manager.enable = true;
}
