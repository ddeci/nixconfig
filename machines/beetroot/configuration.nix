{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/laptop.nix
  ];

  networking.hostName = "beetroot";
  nixpkgs.hostPlatform = "x86_64-linux";
}
