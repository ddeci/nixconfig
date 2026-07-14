_: {
  perSystem =
    { pkgs, ... }:
    {
      treefmt.projectRootFile = ".git/config";
      treefmt.programs = {
        deadnix.enable = true;
        nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
        };
        shellcheck.enable = true;
        statix.enable = true;
      };
    };
}
