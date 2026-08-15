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
    networkmanager.enable = true;
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

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.gnome.Papers.desktop";
      "audio/mpeg" = "mpv.desktop";
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
    mpv
    nautilus
    obsidian
    papers
    papirus-icon-theme
    pavucontrol
    playerctl
    spotify
    vesktop
    wl-clipboard
    xdg-utils
  ];
}
