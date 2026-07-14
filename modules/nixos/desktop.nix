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

  environment.systemPackages = with pkgs; [
    firefox
    kitty
    nautilus
    pavucontrol
    playerctl
    wl-clipboard
    xdg-utils
  ];
}
