{
  inputs,
  self,
  ...
}:
{
  imports = [
    self.users.dima.nixosModule
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.dima = import ../home/dima.nix;
  };
}
