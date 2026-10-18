{ inputs, self, ... }:
{
  imports = [
    self.users.dima.nixosModule
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.dima = import ../home/dima.nix;
  };
}
