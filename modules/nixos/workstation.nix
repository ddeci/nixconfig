# Interactive machines: agent tooling and the parts of dima's home profile
# (herdr, kagi-search) that servers don't need.
{ pkgs, ... }:
{
  imports = [ ./llm-tools.nix ];

  home-manager.users.dima.imports = [ ../home/workstation.nix ];

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
