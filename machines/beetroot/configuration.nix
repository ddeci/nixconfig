{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/mariadb.nix
    ../../modules/nixos/virtualbox.nix
  ];

  networking.hostName = "beetroot";
  nixpkgs.hostPlatform = "x86_64-linux";
}
