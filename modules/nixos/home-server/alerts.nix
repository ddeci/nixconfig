# Prometheus alert rules -> Alertmanager -> self-hosted ntfy -> phone.
# The ntfy server's public URL (services.ntfy-sh.settings.base-url) is set per
# machine; subscribe to the "rack" topic on it in the ntfy app.
{ config, ... }:
let
  ntfyPort = 2586;
  topic = "rack";
  alertmanagerPort = config.services.prometheus.alertmanager.port;
  smartctlPort = config.services.prometheus.exporters.smartctl.port;

  rule =
    {
      alert,
      expr,
      for,
      summary,
      severity ? "warning",
    }:
    {
      inherit alert expr for;
      labels = { inherit severity; };
      annotations = { inherit summary; };
    };
in
{
  services.ntfy-sh = {
    enable = true;
    settings.listen-http = ":${toString ntfyPort}";
  };
  networking.firewall.allowedTCPPorts = [ ntfyPort ];

  # The smartctl exporter runs with the smartctl-exporter-access group, but
  # NVMe controller nodes are root-only by default; hand them to that group.
  services.udev.extraRules = ''
    SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="smartctl-exporter-access", MODE="0660"
  '';

  services.prometheus = {
    exporters.smartctl = {
      enable = true;
      listenAddress = "127.0.0.1";
    };

    scrapeConfigs = [
      {
        job_name = "smartctl";
        static_configs = [ { targets = [ "127.0.0.1:${toString smartctlPort}" ]; } ];
      }
    ];

    alertmanagers = [
      { static_configs = [ { targets = [ "127.0.0.1:${toString alertmanagerPort}" ]; } ]; }
    ];

    alertmanager = {
      enable = true;
      listenAddress = "127.0.0.1";
      configuration = {
        route = {
          receiver = "ntfy";
          group_by = [ "alertname" ];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "12h";
        };
        receivers = [
          {
            name = "ntfy";
            webhook_configs = [
              {
                # ntfy's built-in template turns the Alertmanager payload into a readable push.
                url = "http://127.0.0.1:${toString ntfyPort}/${topic}?template=alertmanager";
                send_resolved = true;
              }
            ];
          }
        ];
      };
    };

    rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "internet";
            rules = [
              (rule {
                alert = "InternetDown";
                expr = ''avg(probe_success{job="ping"}) == 0'';
                for = "2m";
                severity = "critical";
                summary = "Internet is down: 1.1.1.1 and 9.9.9.9 unreachable";
              })
              (rule {
                alert = "PacketLoss";
                expr = ''100 * (1 - avg(avg_over_time(probe_success{job="ping"}[10m]))) > 5'';
                for = "5m";
                summary = "Internet packet loss above 5%";
              })
              (rule {
                alert = "HighLatency";
                expr = ''1000 * avg(probe_icmp_duration_seconds{job="ping",phase="rtt"} and on(instance) probe_success{job="ping"} == 1) > 100'';
                for = "10m";
                summary = "Internet ping above 100 ms";
              })
            ];
          }
          {
            name = "dns";
            rules = [
              (rule {
                alert = "DnsDown";
                expr = ''up{job="blocky"} == 0'';
                for = "2m";
                severity = "critical";
                summary = "Blocky (network DNS) is not responding";
              })
              (rule {
                alert = "BlocklistEmpty";
                expr = "sum(blocky_denylist_cache_entries) == 0";
                for = "10m";
                summary = "Blocky has no blocklist loaded; ads are not being blocked";
              })
              (rule {
                alert = "BlockingDisabled";
                expr = "min(blocky_blocking_enabled) == 0";
                for = "5m";
                summary = "Blocky's ad blocking is switched off";
              })
            ];
          }
          {
            name = "host";
            rules = [
              (rule {
                alert = "HostHot";
                expr = ''max(node_hwmon_temp_celsius{chip="platform_coretemp_0"}) > 85'';
                for = "5m";
                summary = "${config.networking.hostName} CPU above 85 °C";
              })
              (rule {
                alert = "MemoryHigh";
                expr = "1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes > 0.9";
                for = "15m";
                summary = "${config.networking.hostName} RAM above 90%";
              })
              (rule {
                alert = "DiskFilling";
                expr = ''node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.15'';
                for = "15m";
                summary = "${config.networking.hostName} disk has less than 15% free";
              })
              (rule {
                alert = "ServiceFailed";
                expr = ''node_systemd_unit_state{state="failed"} == 1'';
                for = "5m";
                summary = "{{ $labels.name }} failed on ${config.networking.hostName}";
              })
            ];
          }
          {
            name = "disk-health";
            rules = [
              (rule {
                alert = "SsdUnhealthy";
                expr = "smartctl_device_smart_status != 1";
                for = "5m";
                severity = "critical";
                summary = "SSD {{ $labels.device }} reports failing SMART health";
              })
              (rule {
                alert = "SsdCriticalWarning";
                expr = "smartctl_device_critical_warning > 0";
                for = "5m";
                severity = "critical";
                summary = "SSD {{ $labels.device }} raised a critical warning";
              })
              (rule {
                alert = "SsdMediaErrors";
                expr = "increase(smartctl_device_media_errors[1h]) > 0";
                for = "0m";
                summary = "SSD {{ $labels.device }} logged new media errors";
              })
            ];
          }
        ];
      })
    ];
  };
}
