_:
{
  programs = {
    bat.enable = true;
    btop.enable = true;
    fastfetch.enable = true;
    gh.enable = true;
    lazygit.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [ "--group-directories-first" ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$directory$git_branch$git_status$nix_shell$line_break$character";
        palette = "dima";
        palettes.dima = {
          blue = "#168bff";
          gray = "#8795a5";
        };
        character = {
          success_symbol = "[❯](bold blue)";
          error_symbol = "[❯](bold red)";
        };
        directory.style = "bold blue";
        git_branch = {
          format = "[$symbol$branch]($style) ";
          style = "gray";
        };
        git_status.style = "bold blue";
        nix_shell = {
          format = "[via $symbol$name]($style) ";
          style = "gray";
          symbol = "❄ ";
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      history = {
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 10000;
        share = true;
        size = 10000;
      };

      initContent = ''
        setopt AUTO_CD
      '';

      shellAliases = {
        v = "nvim";

        ls = "eza --icons=auto --group-directories-first";
        ll = "eza -la --icons=auto --group-directories-first";
        lt = "eza --tree --level=2 --icons=auto";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "-" = "cd -";

        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        gd = "git diff";
        gco = "git checkout";
        gb = "git branch";
        glog = "git log --oneline --graph --decorate";

        cpu = "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10";
        mem = "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 10";
        ports = "ss -tulanp";

        df = "df -h";
        du = "du -h";
        free = "free -h";
        copy = "wl-copy";
        paste = "wl-paste";

        dms-reload = "dms restart";
        niri-restart = "systemctl --user restart niri";

        nixconfig = "cd ~/git/nixconfig";
        nvimconfig = "nvim ~/git/nixconfig/modules/home/neovim/init.lua";
        rebuild = "sudo nixos-rebuild switch --flake ~/git/nixconfig#beetroot";
      };
    };
  };
}
