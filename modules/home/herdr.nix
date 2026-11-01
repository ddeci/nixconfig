{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  herdr = lib.getExe config.programs.herdr.package;
in
{
  programs.herdr = {
    enable = true;
    # Same store path as the system copy in modules/nixos/llm-tools.nix; set here
    # so the module's reload-config onChange hook can find the binary.
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
    settings = {
      onboarding = false;
      keys = {
        prefix = "ctrl+space";
        copy_mode = "prefix+space";
      };
    };
  };

  # Integration files are versioned with herdr; reinstall them from the
  # installed binary so they never drift from the running herdr version.
  # herdr refuses (exit 1) when the agent's extension dir doesn't exist yet,
  # i.e. before the agent has run once, so skip those.
  home.activation.herdrIntegrations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "$HOME/.omp/agent/extensions" ]; then
      run ${herdr} integration install omp
    fi
    if [ -d "$HOME/.pi/agent/extensions" ]; then
      run ${herdr} integration install pi
    fi
  '';
}
