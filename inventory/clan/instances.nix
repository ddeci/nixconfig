{
  state-version = {
    module = {
      name = "importer";
      input = "clan-core";
    };
    roles.default.tags = [ "all" ];
    roles.default.settings.extraModules = [
      { clan.core.state-version.enable = true; }
    ];
  };

  wifi = {
    module = {
      name = "wifi";
      input = "clan-core";
    };
    roles.default = {
      tags = [ "wifi" ];
      settings.networks.home = { };
    };
  };

  tailnet = {
    module = {
      name = "@dimaroot/tailscale";
      input = "self";
    };
    roles.peer.tags = [ "tailscale" ];
  };
}
