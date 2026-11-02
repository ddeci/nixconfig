let
  lanSubnet = "192.168.8.0/24";
  lanAddress = "192.168.8.101"; # DHCP reservation on the Beryl
  tailnetAddress = "100.102.24.84";
  router = "192.168.8.1";
in
{
  imports = [
    ../../modules/nixos/base.nix
    ../../modules/nixos/home-server
  ];

  networking.hostName = "daikon";
  nixpkgs.hostPlatform = "x86_64-linux";

  # systemd-resolved keeps 127.0.0.53; Blocky binds explicit addresses beside it.
  services.blocky.settings = {
    ports.dns = [
      "127.0.0.1:53"
      "${lanAddress}:53"
      "${tailnetAddress}:53"
    ];
    # Local hostnames (*.lan) and reverse lookups come from the Beryl's DHCP leases.
    conditional.mapping = {
      lan = router;
      "8.168.192.in-addr.arpa" = router;
    };
    clientLookup.upstream = router;
  };

  # LAN address works at home and, via the subnet route, from anywhere on the tailnet.
  services.ntfy-sh.settings.base-url = "http://${lanAddress}:2586";

  # Expose the home LAN to the tailnet; the route must be approved in the admin console.
  services.tailscale = {
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-routes=${lanSubnet}"
      "--accept-routes=false"
    ];
  };
}
