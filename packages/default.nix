{
  # Configured applications built with nix-wrapper-modules.
  wrappers = {
    git.path = ./git;
    niri.path = ./niri;
  };

  # Ordinary callPackage packages and overrides belong here.
  packages = { };
}
