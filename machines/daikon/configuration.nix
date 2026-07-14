{
  imports = [ ../../modules/nixos/base.nix ];

  networking.hostName = "daikon";
  nixpkgs.hostPlatform = "x86_64-linux";
}
