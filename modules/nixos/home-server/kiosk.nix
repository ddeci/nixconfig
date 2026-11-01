# Full-screen Grafana dashboard on the attached display (the 1U rack touchscreen).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  grafanaUrl = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";

  # The 1U panel is 1920x440, but its controller only accepts 1920x1080 and
  # squeezes that vertically onto the panel. Lay the page out at the panel's
  # real size and pre-stretch it by the same factor so it looks right.
  panel = {
    width = 1920;
    height = 440;
  };
  outputHeight = 1080;
  stretch = outputHeight * 1.0 / panel.height;

  stat =
    {
      x,
      w,
      title,
      expr,
      unit ? "none",
      decimals ? null,
      steps ? [ { color = "green"; } ],
      mappings ? [ ],
      colorMode ? "value",
      # Grafana auto-fits the value to the tile; wide tiles need a cap so
      # the number does not crowd out the label.
      valueSize ? null,
      extra ? { },
    }:
    {
      type = "stat";
      gridPos = {
        inherit x w;
        y = 0;
        # Fills the 440px viewport so Grafana's footer falls below the fold.
        h = 11;
      };
      datasource = {
        type = "prometheus";
        uid = "prometheus";
      };
      targets = [
        {
          refId = "A";
          inherit expr;
          instant = true;
          range = false;
        }
      ];
      options = {
        reduceOptions = {
          calcs = [ "lastNotNull" ];
          fields = "";
          values = false;
        };
        textMode = "value_and_name";
        inherit colorMode;
        graphMode = "none";
        justifyMode = "center";
        text = {
          titleSize = 40;
        }
        // lib.optionalAttrs (valueSize != null) { inherit valueSize; };
      };
      fieldConfig = {
        defaults = {
          displayName = title;
          inherit unit decimals mappings;
          color.mode = "thresholds";
          thresholds = {
            mode = "absolute";
            steps = map (s: { value = null; } // s) steps;
          };
        };
        overrides = [ ];
      };
    }
    // extra;

  rackDashboard = pkgs.writeTextDir "rack.json" (
    builtins.toJSON {
      uid = "rack";
      title = "Rack";
      editable = false;
      schemaVersion = 39;
      refresh = "30s";
      time = {
        from = "now-6h";
        to = "now";
      };
      panels = [
        (stat {
          x = 0;
          w = 5;
          title = "Blocked today";
          expr = ''sum(increase(blocky_response_total{response_type="BLOCKED"}[$__range]))'';
          decimals = 0;
          valueSize = 140;
          steps = [ { color = "blue"; } ];
          extra = {
            timeFrom = "now/d";
            hideTimeOverride = true;
          };
        })
        (stat {
          x = 5;
          w = 3;
          title = "DNS p95";
          expr = "1000 * histogram_quantile(0.95, sum by (le) (rate(blocky_request_duration_seconds_bucket[5m])))";
          unit = "ms";
          decimals = 0;
          steps = [
            { color = "green"; }
            {
              color = "orange";
              value = 100;
            }
            {
              color = "red";
              value = 500;
            }
          ];
        })
        {
          type = "timeseries";
          title = "CPU · RAM (1h)";
          gridPos = {
            x = 8;
            y = 0;
            w = 9;
            h = 11;
          };
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          timeFrom = "1h";
          hideTimeOverride = true;
          targets = [
            {
              refId = "A";
              expr = ''100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[2m])))'';
              legendFormat = "CPU";
            }
            {
              refId = "B";
              expr = "100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)";
              legendFormat = "RAM";
            }
          ];
          options = {
            legend = {
              showLegend = true;
              displayMode = "list";
              placement = "bottom";
              calcs = [ "lastNotNull" ];
            };
            tooltip.mode = "none";
          };
          fieldConfig = {
            defaults = {
              unit = "percent";
              min = 0;
              max = 100;
              decimals = 0;
              color.mode = "palette-classic";
              custom = {
                lineWidth = 3;
                fillOpacity = 20;
                gradientMode = "opacity";
                showPoints = "never";
                axisPlacement = "hidden";
                axisGridShow = false;
              };
            };
            overrides =
              map
                (s: {
                  matcher = {
                    id = "byName";
                    options = s.name;
                  };
                  properties = [
                    {
                      id = "color";
                      value = {
                        mode = "fixed";
                        fixedColor = s.color;
                      };
                    }
                  ];
                })
                [
                  {
                    name = "CPU";
                    color = "green";
                  }
                  {
                    name = "RAM";
                    color = "blue";
                  }
                ];
          };
        }
        (stat {
          x = 17;
          w = 3;
          title = "Temp";
          expr = ''max(node_hwmon_temp_celsius{chip="platform_coretemp_0"})'';
          unit = "celsius";
          decimals = 0;
          steps = [
            { color = "green"; }
            {
              color = "orange";
              value = 70;
            }
            {
              color = "red";
              value = 85;
            }
          ];
        })
        (stat {
          x = 20;
          w = 4;
          title = "Uptime";
          expr = "time() - node_boot_time_seconds";
          unit = "s";
          decimals = 0;
          steps = [ { color = "blue"; } ];
        })
      ];
    }
  );

  page = pkgs.writeText "rack.html" ''
    <!doctype html>
    <html>
      <head>
        <style>
          html, body { margin: 0; width: 100%; height: 100%; overflow: hidden; background: #111217; }
          iframe {
            border: 0;
            width: ${toString panel.width}px;
            /* Extra room below the panel area pushes Grafana's footer off-screen. */
            height: ${toString (panel.height + 24)}px;
            transform: scale(1, ${toString stretch});
            transform-origin: 0 0;
            /* Display only: a stray tap must not navigate the dashboard. */
            pointer-events: none;
          }
        </style>
      </head>
      <body>
        <iframe scrolling="no" src="${grafanaUrl}/d/rack?kiosk&_dash.hideTimePicker&_dash.hideVariables&_dash.hideLinks&refresh=30s"></iframe>
      </body>
    </html>
  '';

  kiosk = pkgs.writeShellScript "grafana-kiosk" ''
    until ${pkgs.curl}/bin/curl -sf ${grafanaUrl}/api/health > /dev/null; do sleep 1; done
    exec ${pkgs.chromium}/bin/chromium \
      --kiosk \
      --incognito \
      --no-first-run \
      --noerrdialogs \
      --disable-infobars \
      --disable-session-crashed-bubble \
      --ozone-platform=wayland \
      'file://${page}'
  '';
in
{
  users.users.kiosk.isNormalUser = true;

  services.cage = {
    enable = true;
    user = "kiosk";
    program = kiosk;
  };

  # cage-tty1 hangs off graphical.target; servers otherwise stop at multi-user.
  systemd.defaultUnit = "graphical.target";

  services.grafana = {
    settings = {
      # Read-only dashboards without login, so the kiosk needs no credentials.
      "auth.anonymous" = {
        enabled = true;
        org_role = "Viewer";
      };
      # The kiosk page frames the dashboard to undo the panel's squeeze.
      security.allow_embedding = true;
    };
    provision.dashboards.settings.providers = [
      {
        name = "rack";
        options.path = rackDashboard;
      }
    ];
  };
}
