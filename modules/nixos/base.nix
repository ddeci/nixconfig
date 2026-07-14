{
  pkgs,
  self,
  ...
}:
{
  imports = [
    ./dima-user.nix
    ./llm-tools.nix
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "dima"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  programs.direnv.enable = true;
  programs.git = {
    enable = true;
    package = self.packages.${pkgs.stdenv.hostPlatform.system}.git;
  };

  environment = {
    variables.EDITOR = "nano";
    systemPackages = with pkgs; [
      curl
      fd
      file
      htop
      jq
      nano
      ripgrep
      tree
      wget
    ];
  };
}
