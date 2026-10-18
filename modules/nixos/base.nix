{
  pkgs,
  self,
  ...
}:
{
  imports = [
    self.users.alex.nixosModule
    ./dima-user.nix
    ./llm-tools.nix
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = self.users.dima.sshKeys ++ self.users.alex.sshKeys;
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      self.users.dima.username
      self.users.alex.username
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
