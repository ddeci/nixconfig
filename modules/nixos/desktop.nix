{
  pkgs,
  self,
  ...
}:
let
  niri = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
in
{
  imports = [ ./pipewire.nix ];

  networking = {
    dhcpcd.enable = false;
    networkmanager.enable = true;
    useDHCP = false;
    useNetworkd = false;
  };

  programs.niri = {
    enable = true;
    package = niri;
  };

  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
      user = "greeter";
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    noto-fonts-color-emoji
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.sessionVariables.DISPLAY = ":0";

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.gnome.Papers.desktop";
      "audio/mpeg" = "mpv.desktop";
      "image/png" = "org.gnome.Loupe.desktop";
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "video/mp4" = "mpv.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };

  environment.systemPackages = with pkgs; [
    file-roller
    firefox
    kitty
    libreoffice-fresh
    loupe
    mpv
    nautilus
    obs-studio
    obsidian
    papers
    papirus-icon-theme
    pavucontrol
    playerctl
    spotify
    vesktop
    wl-clipboard
    xdg-utils
    xwayland-satellite
  ];
}
