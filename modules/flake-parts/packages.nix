{
  inputs,
  lib,
  ...
}:
let
  registry = import ../../packages;
in
{
  imports = [ inputs.wrapper-modules.flakeModules.wrappers ];

  flake.wrappers = lib.mapAttrs (_name: entry: {
    imports = [ entry.path ];
    _module.args = {
      inherit inputs;
      inherit (inputs) self;
    };
  }) registry.wrappers;

  perSystem =
    {
      inputs',
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      wrappers = {
        control_type = "build";
        inherit pkgs;
        packages = lib.mapAttrs (_name: _entry: true) registry.wrappers;
      };

      packages = lib.mapAttrs (
        _name: entry:
        pkgs.callPackage entry.path {
          inherit inputs inputs';
          inherit (inputs) self;
        }
      ) registry.packages;
    };
}
