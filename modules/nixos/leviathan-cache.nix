{
  nix.settings = {
    extra-substituters = [ "http://leviathan.cymric-daggertooth.ts.net:5000?priority=50" ];
    extra-trusted-public-keys = [
      "harmonia-leviathan:iCmntZCA/nIZZ6rqdkJwUCpPv1G+259hZ8JTLrlfRz8="
    ];
    # Fail fast when off the tailnet instead of stalling every build.
    connect-timeout = 5;
  };
}
