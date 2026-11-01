# Full-screen Grafana dashboard on the attached display (the 1U rack touchscreen).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  grafanaUrl = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
  host = config.networking.hostName;

  # The 1U panel is 1920x440, but its controller only accepts 1920x1080 and
  # squeezes that vertically onto the panel. Lay the page out at the panel's
  # real size and pre-stretch it by the same factor so it looks right.
  panel = {
    width = 1920;
    height = 440;
  };
  outputHeight = 1080;
  stretch = outputHeight * 1.0 / panel.height;
  # The panel crops its edges (overscan); keep content inside this margin,
  # in panel pixels.
  overscan = {
    x = 24;
    y = 6;
  };

  datasource = {
    type = "prometheus";
    uid = "prometheus";
  };

  thresholds = steps: {
    mode = "absolute";
    steps = map (s: { value = null; } // s) steps;
  };

  # Every group is one full-height panel with one row per metric; overrides
  # give each row its own unit, range and colours.
  rowTargets =
    instant: rows:
    lib.imap0 (i: r: {
      refId = builtins.elemAt [ "A" "B" "C" "D" ] i;
      inherit (r) expr;
      legendFormat = r.name;
      inherit instant;
      range = !instant;
    }) rows;

  rowOverrides = map (r: {
    matcher = {
      id = "byName";
      options = r.name;
    };
    properties = [
      {
        id = "unit";
        value = r.unit;
      }
      {
        id = "decimals";
        value = 0;
      }
      {
        id = "thresholds";
        value = thresholds r.steps;
      }
    ]
    ++ lib.optionals (r ? max) [
      {
        id = "min";
        value = r.min or 0;
      }
      {
        id = "max";
        value = r.max;
      }
    ];
  });

  group =
    {
      x,
      w,
      type,
      rows,
      options,
      instant ? true,
      extra ? { },
    }:
    {
      inherit type datasource;
      gridPos = {
        inherit x w;
        y = 0;
        # Fills the viewport inside the overscan margin, so Grafana's footer
        # falls below the fold.
        h = 11;
      };
      targets = rowTargets instant rows;
      options = {
        reduceOptions = {
          calcs = [ "lastNotNull" ];
          fields = "";
          values = false;
        };
        orientation = "horizontal";
      }
      // options;
      fieldConfig = {
        defaults.color.mode = "thresholds";
        overrides = rowOverrides rows;
      };
    }
    // extra;

  stacked =
    {
      x,
      w,
      rows,
      sparkline ? false,
    }:
    group {
      inherit x w rows;
      type = "stat";
      instant = !sparkline;
      options = {
        textMode = "value_and_name";
        colorMode = "value";
        graphMode = if sparkline then "area" else "none";
        justifyMode = "auto";
        text = {
          titleSize = 40;
          valueSize = 72;
        };
      };
      extra = lib.optionalAttrs sparkline {
        timeFrom = "1h";
        hideTimeOverride = true;
      };
    };

  # Grafana sizes the label column at its own auto font and right-aligns the
  # (smaller) label, leaving dead space on the left. Trailing non-breaking
  # spaces (plain spaces get collapsed) nudge each label back toward the
  # middle. Per-row counts were measured in the rendered DOM: every label
  # sits within ~6px of centred and both groups' bars end up a segment apart.
  nbsp = builtins.fromJSON ''"\u00a0"'';

  meters =
    {
      x,
      w,
      rows,
    }:
    group {
      inherit x w;
      rows = map (r: r // { name = r.name + lib.concatStrings (lib.replicate (r.pad or 0) nbsp); }) rows;
      type = "bargauge";
      options = {
        displayMode = "lcd";
        valueMode = "color";
        namePlacement = "left";
        showUnfilled = true;
        sizing = "auto";
        text = {
          titleSize = 36;
          valueSize = 44;
        };
      };
    };

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
        (meters {
          x = 0;
          w = 9;
          rows = [
            {
              name = "Ping";
              pad = 5;
              expr = ''1000 * avg(probe_icmp_duration_seconds{job="ping",phase="rtt"} and on(instance) probe_success{job="ping"} == 1)'';
              unit = "ms";
              max = 100;
              steps = [
                { color = "green"; }
                {
                  color = "orange";
                  value = 50;
                }
                {
                  color = "red";
                  value = 80;
                }
              ];
            }
            {
              name = "Loss";
              pad = 5;
              expr = ''100 * (1 - avg(avg_over_time(probe_success{job="ping"}[5m])))'';
              unit = "percent";
              max = 10;
              steps = [
                { color = "green"; }
                {
                  color = "orange";
                  value = 1;
                }
                {
                  color = "red";
                  value = 5;
                }
              ];
            }
            {
              name = "DNS";
              pad = 5;
              expr = "1000 * histogram_quantile(0.95, sum by (le) (rate(blocky_request_duration_seconds_bucket[5m])))";
              unit = "ms";
              max = 200;
              steps = [
                { color = "green"; }
                {
                  color = "orange";
                  value = 100;
                }
                {
                  color = "red";
                  value = 150;
                }
              ];
            }
          ];
        })
        (stacked {
          x = 9;
          w = 6;
          sparkline = true;
          rows = [
            {
              name = "Devices";
              # Clients that used DNS in the last hour, minus this box itself.
              expr = ''count(sum by (client) (increase(blocky_client_response_total{client!~"${host}.*|127\\.0\\.0\\.1"}[1h])) > 0) or vector(0)'';
              unit = "none";
              steps = [ { color = "blue"; } ];
            }
            {
              name = "Blocked";
              expr = ''100 * sum(increase(blocky_response_total{response_type="BLOCKED"}[24h])) / sum(increase(blocky_query_total[24h]))'';
              unit = "percent";
              steps = [ { color = "purple"; } ];
            }
          ];
        })
        (meters {
          x = 15;
          w = 9;
          rows = [
            {
              name = "CPU";
              pad = 6;
              expr = ''100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[2m])))'';
              unit = "percent";
              max = 100;
              steps = [
                { color = "green"; }
                {
                  color = "orange";
                  value = 70;
                }
                {
                  color = "red";
                  value = 90;
                }
              ];
            }
            {
              name = "RAM";
              pad = 6;
              expr = "100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)";
              unit = "percent";
              max = 100;
              steps = [
                { color = "green"; }
                {
                  color = "orange";
                  value = 80;
                }
                {
                  color = "red";
                  value = 90;
                }
              ];
            }
            {
              name = "Temp";
              pad = 5;
              expr = ''max(node_hwmon_temp_celsius{chip="platform_coretemp_0"})'';
              unit = "celsius";
              max = 100;
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
            }
          ];
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
          /* Visible area inside the overscan margin; clips Grafana's footer. */
          .safe {
            position: absolute;
            left: ${toString overscan.x}px;
            top: ${toString (overscan.y * stretch)}px;
            width: ${toString (panel.width - 2 * overscan.x)}px;
            height: ${toString ((panel.height - 2 * overscan.y) * stretch)}px;
            overflow: hidden;
          }
          iframe {
            border: 0;
            width: 100%;
            /* Extra room below the panel area pushes Grafana's footer out of view. */
            height: ${toString (panel.height - 2 * overscan.y + 24)}px;
            transform: scale(1, ${toString stretch});
            transform-origin: 0 0;
            /* Display only: a stray tap must not navigate the dashboard. */
            pointer-events: none;
          }
        </style>
      </head>
      <body>
        <div class="safe">
          <iframe scrolling="no" src="${grafanaUrl}/d/rack?kiosk&_dash.hideTimePicker&_dash.hideVariables&_dash.hideLinks&refresh=30s"></iframe>
        </div>
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
