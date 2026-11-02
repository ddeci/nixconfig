# Network-wide DNS with ad/tracker blocking. Listen addresses and LAN-specific
# routing are set per machine (see machines/daikon/configuration.nix).
{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        # Bind addresses that are not up yet (e.g. Tailscale at boot).
        freeBind = true;
        # Metrics/API only; scraped locally by Prometheus.
        http = "127.0.0.1:4000";
      };

      upstreams.groups.default = [
        "https://one.one.one.one/dns-query"
        "https://dns.quad9.net/dns-query"
      ];
      bootstrapDns = [
        {
          upstream = "https://one.one.one.one/dns-query";
          ips = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        }
        {
          upstream = "https://dns.quad9.net/dns-query";
          ips = [
            "9.9.9.9"
            "149.112.112.112"
          ];
        }
      ];

      blocking = {
        denylists = {
          ads = [
            # HaGeZi Pro, wildcard format (the one HaGeZi lists for Blocky).
            "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.txt"
          ];
          # Firefox's canary domain: answering NXDOMAIN makes Firefox keep using
          # the network's DNS instead of its own DoH, which would bypass Blocky.
          # (Entries with a newline are inline lists, not URLs.)
          doh-canary = [ "use-application-dns.net\n" ];
        };
        clientGroupsBlock.default = [
          "ads"
          "doh-canary"
        ];
        # NXDOMAIN rather than 0.0.0.0: Firefox treats 0.0.0.0 as a real answer
        # for the canary, and ads fail to load either way.
        blockType = "nxDomain";
        # Serve DNS right away and keep retrying the list download for ~5 min:
        # clan disables wait-online, and after a power cut the router's WAN
        # comes up well after this box has a link.
        loading = {
          strategy = "fast";
          downloads = {
            attempts = 30;
            cooldown = "10s";
          };
        };
      };

      caching.prefetching = true;
      prometheus.enable = true;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
