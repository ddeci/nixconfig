{ self, ... }:
{
  perSystem =
    {
      config,
      lib,
      system,
      ...
    }:
    let
      machines = lib.filterAttrs (
        _name: machine: machine.pkgs.stdenv.hostPlatform.system == system
      ) self.nixosConfigurations;
      registry = import ../../packages;
      packageNames = builtins.attrNames ((registry.packages or { }) // (registry.wrappers or { }));
    in
    {
      checks =
        lib.mapAttrs' (
          name: machine: lib.nameValuePair "nixos-${name}" machine.config.system.build.toplevel
        ) machines
        // lib.genAttrs packageNames (name: config.packages.${name});
    };
}
