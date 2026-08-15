{
  config,
  pkgs,
  ...
}:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5LZiPjCdKk1YN+q19kmXzI7LWjKXlMTaHtAqX13+Ir dima@beetroot"
  ];
in
{
  users.mutableUsers = false;

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;

    dima = {
      description = "Dima";
      uid = 8070;
      isNormalUser = true;
      createHome = true;
      shell = pkgs.bashInteractive;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "input"
        "kvm"
      ];
      openssh.authorizedKeys.keys = sshKeys;
      hashedPasswordFile = config.clan.core.vars.generators.dima-password.files.password-hash.path;
    };
  };

  clan.core.vars.generators.dima-password = {
    share = true;
    files.password-hash.neededFor = "users";
    prompts.password = {
      description = "Login password for Dima";
      type = "hidden";
      persist = true;
    };
    runtimeInputs = [ pkgs.mkpasswd ];
    script = ''
      mkpasswd -s -m sha-512 < "$prompts"/password > "$out"/password-hash
    '';
  };
}
