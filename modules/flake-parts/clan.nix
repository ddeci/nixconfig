{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      clan.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

  clan = {
    meta.name = "dimaroot";
    inventory = import ../../inventory/clan;
    modules = import ../clan;
    specialArgs = {
      inherit inputs;
      inherit (inputs) self;
    };
  };
}
