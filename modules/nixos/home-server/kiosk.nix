# Full-screen Grafana dashboard on the attached display (the rack touchscreen).
{ config, pkgs, ... }:
let
  grafanaUrl = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
  dashboardUrl = "${grafanaUrl}/d/blocky-dns?kiosk&refresh=30s&from=now-6h&to=now";

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
      '${dashboardUrl}'
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

  # Read-only dashboards without login, so the kiosk needs no credentials.
  services.grafana.settings."auth.anonymous" = {
    enabled = true;
    org_role = "Viewer";
  };
}
