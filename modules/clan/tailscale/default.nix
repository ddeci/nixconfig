_: {
  _class = "clan.service";

  manifest = {
    name = "@dimaroot/tailscale";
    description = "Enroll Tailscale peers with a Clan-managed auth key";
    categories = [ "Utility" ];
    readme = builtins.readFile ./README.md;
  };

  roles.peer = {
    description = "A Tailscale peer enrolled with a shared auth key";

    perInstance =
      { instanceName, ... }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            generatorName = "tailscale-${instanceName}";
          in
          {
            clan.core.vars.generators.${generatorName} = {
              share = true;
              files.auth-key = { };
              runtimeInputs = [ pkgs.coreutils ];

              prompts.auth-key = {
                description = "Reusable Tailscale auth key for '${instanceName}'";
                type = "hidden";
                persist = true;
              };

              script = ''
                cat "$prompts"/auth-key > "$out"/auth-key
              '';
            };

            services.tailscale = {
              enable = true;
              authKeyFile = config.clan.core.vars.generators.${generatorName}.files.auth-key.path;
              extraSetFlags = lib.mkDefault [ "--accept-routes=false" ];
            };
          };
      };
  };
}
