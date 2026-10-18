let
  importUser =
    file:
    let
      name = builtins.replaceStrings [ ".nix" ] [ "" ] file;
    in
    {
      inherit name;
      value = import (./. + "/${file}");
    };

  files = builtins.filter (f: f != "default.nix" && builtins.match ".*\\.nix" f != null) (
    builtins.attrNames (builtins.readDir ./.)
  );
in
builtins.listToAttrs (map importUser files)
