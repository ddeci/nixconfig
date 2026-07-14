_: {
  perSystem =
    {
      inputs',
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          inputs'.clan-core.packages.clan-cli
          pkgs.git
          pkgs.nil
        ];
      };
    };
}
