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
    settings = {
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = kdlFlag;
          natural-scroll = kdlFlag;
        };
      };

      layout = {
        gaps = 12;
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
        "Mod+Space" = dms "spotlight";
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
      };
    };
  };
}
