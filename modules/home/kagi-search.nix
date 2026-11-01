{ inputs, osConfig, ... }:
{
  imports = [ inputs.mics-skills.homeModules.kagi-search ];

  programs.mics-skills.skillDirs = [ ".omp/agent/skills" ];

  # kagi-search runs password_command without a shell (str.split), so keep it a
  # plain argv. The secret is a clan var; see modules/nixos/dima-user.nix.
  xdg.configFile."kagi/config.json".text = builtins.toJSON {
    password_command = "cat ${osConfig.clan.core.vars.generators.kagi-session-link.files.session-link.path}";
    timeout = 30;
    max_retries = 5;
  };
}
