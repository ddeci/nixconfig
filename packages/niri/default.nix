{
  wlib,
  pkgs,
  ...
}:
let
  # Emit a flag-like KDL node with no value or child block.
  kdlFlag = _: { };
  dms = command: _: {
    props.repeat = false;
    content.spawn = [
      "dms"
      "ipc"
      command
      "toggle"
    ];
  };
in
{
  imports = [ wlib.wrapperModules.niri ];

  config = {
    package = pkgs.niri;

    # DMS owns live visual settings; Nix owns behavior and keybindings.
    extraSettings =
      map
        (path: {
          include = [
            { optional = true; }
            path
          ];
        })
        [
          "~/.config/niri/dms/alttab.kdl"
          "~/.config/niri/dms/colors.kdl"
          "~/.config/niri/dms/cursor.kdl"
          "~/.config/niri/dms/layout.kdl"
          "~/.config/niri/dms/wpblur.kdl"
        ];

    settings = {
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = kdlFlag;
          natural-scroll = kdlFlag;
        };
        trackpoint.accel-speed = -0.5;
      };

      layout = {
        center-focused-column = "never";
        default-column-width.proportion = 0.5;
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
      };

      prefer-no-csd = kdlFlag;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = kdlFlag;
        "Mod+Return" = _: {
          props.hotkey-overlay-title = "Open a terminal";
          content.spawn = "kitty";
        };
        "Mod+B" = _: {
          props.hotkey-overlay-title = "Open Firefox";
          content.spawn = "firefox";
        };
        "Mod+E" = _: {
          props.hotkey-overlay-title = "Open Files";
          content.spawn = "nautilus";
        };
        "Mod+Space" = dms "spotlight-bar";
        "Mod+N" = dms "notifications";
        "Mod+Comma" = dms "settings";
        "Mod+P" = dms "notepad";
        "Mod+X" = dms "powermenu";
        "Mod+V" = dms "clipboard";
        "Super+Alt+L" = _: {
          props.repeat = false;
          content.spawn = [
            "dms"
            "ipc"
            "lock"
            "lock"
          ];
        };
        "Mod+Ctrl+L" = _: {
          props.repeat = false;
          content.spawn = [
            "dms"
            "ipc"
            "lock"
            "lock"
          ];
        };

        "XF86PowerOff" = dms "powermenu";
        "XF86AudioRaiseVolume".spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%+"
        ];
        "XF86AudioLowerVolume".spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "5%-"
        ];
        "XF86AudioMute".spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SINK@"
          "toggle"
        ];
        "XF86AudioMicMute".spawn = [
          "wpctl"
          "set-mute"
          "@DEFAULT_AUDIO_SOURCE@"
          "toggle"
        ];
        "XF86MonBrightnessUp".spawn = [
          "brightnessctl"
          "set"
          "+5%"
        ];
        "XF86MonBrightnessDown".spawn = [
          "brightnessctl"
          "set"
          "5%-"
        ];
        "XF86AudioPlay".spawn = [
          "playerctl"
          "play-pause"
        ];
        "XF86AudioNext".spawn = [
          "playerctl"
          "next"
        ];
        "XF86AudioPrev".spawn = [
          "playerctl"
          "previous"
        ];
        "XF86AudioStop".spawn = [
          "playerctl"
          "stop"
        ];

        "Mod+Q".close-window = kdlFlag;
        "Mod+H".focus-column-left = kdlFlag;
        "Mod+J".focus-window-or-workspace-down = kdlFlag;
        "Mod+K".focus-window-or-workspace-up = kdlFlag;
        "Mod+L".focus-column-right = kdlFlag;
        "Mod+Shift+H".move-column-left = kdlFlag;
        "Mod+Shift+J".move-window-down-or-to-workspace-down = kdlFlag;
        "Mod+Shift+K".move-window-up-or-to-workspace-up = kdlFlag;
        "Mod+Shift+L".move-column-right = kdlFlag;
        "Mod+O".toggle-overview = kdlFlag;
        "Mod+R".switch-preset-column-width = kdlFlag;
        "Mod+F".maximize-column = kdlFlag;
        "Mod+Shift+F".fullscreen-window = kdlFlag;
        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Print".screenshot = kdlFlag;
        "Mod+Shift+S".screenshot = kdlFlag;
      };
    };
  };
}
