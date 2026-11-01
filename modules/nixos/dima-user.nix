{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [
    self.users.dima.nixosModule
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    users.dima = import ../home/dima.nix;
  };

  # Kagi session link for the kagi-search skill (modules/home/kagi-search.nix).
  clan.core.vars.generators.kagi-session-link = {
    share = true;
    files.session-link.owner = "dima";
    runtimeInputs = [ pkgs.coreutils ];

    prompts.session-link = {
      description = "Kagi session link (kagi.com/settings?p=api → Session Link)";
      type = "hidden";
      persist = true;
    };

    script = ''
      cat "$prompts"/session-link > "$out"/session-link
    '';
  };
}
