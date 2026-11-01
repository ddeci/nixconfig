{ config, pkgs, ... }:
let
  prometheusPort = config.services.prometheus.port;
  nodePort = config.services.prometheus.exporters.node.port;
  grafanaSecrets = config.clan.core.vars.generators.grafana.files;

  dashboards = pkgs.linkFarm "grafana-dashboards" [
    {
      name = "blocky.json";
      path = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/0xERR0R/blocky/v0.35.0/docs/blocky-grafana.json";
        hash = "sha256-8u5OYL3CWSdGCh4PNvyobsQ47gIqWc+4NULUOWRYFwI=";
      };
    }
    {
      name = "node-exporter-full.json";
      path = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/6c2de7ebaea4dd1dad7089d86d75de71417a3d0b/prometheus/node-exporter-full.json";
        hash = "sha256-ikYbkQxODl5o+zEHtgApc1M0U+Crxih9g8z33Y0+iu4=";
      };
    }
  ];
in
{
  clan.core.vars.generators.grafana = {
    files.admin-password.owner = "grafana";
    files.secret-key.owner = "grafana";
    runtimeInputs = [ pkgs.openssl ];
    script = ''
      openssl rand -base64 24 | tr -d '\n' > "$out"/admin-password
      openssl rand -hex 32 | tr -d '\n' > "$out"/secret-key
    '';
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "90d";
    globalConfig.scrape_interval = "15s";

    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      enabledCollectors = [ "systemd" ];
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "127.0.0.1:${toString prometheusPort}" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:${toString nodePort}" ]; } ];
      }
      {
        job_name = "blocky";
        static_configs = [ { targets = [ config.services.blocky.settings.ports.http ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{${grafanaSecrets.admin-password.path}}";
        secret_key = "$__file{${grafanaSecrets.secret-key.path}}";
      };
      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "prometheus";
          url = "http://127.0.0.1:${toString prometheusPort}";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "home-server";
          options.path = dashboards;
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.grafana.settings.server.http_port ];
}
