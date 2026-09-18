{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.personal.programs.hyprland;
in
{
  options.personal.programs.hyprland = {
    enable = lib.mkEnableOption "Enable hyprland and provision the configuration";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Hyprland package to use. Set to `null` if hyprland binary is provided globally";
    };

    portalPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Hyprland portal package to use (xdg-desktop-portal-hyprland). Set to `null` if hyprland portal is provided globally";
    };

    programMenu = lib.mkOption {
      type = lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.wofi;
          };
          runCmd = lib.mkOption {
            type = lib.types.nonEmptyStr;
            default = if cfg.programMenu.package == pkgs.wofi then "--show run" else "";
            description = "Options and arguments to pass to the program upon execution (omit the program name!)";
          };
        };
      };
    };

    notificationsPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mako;
    };

    fileManagerPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kdePackages.dolphin;
    };

    withSystemd = lib.mkEnableOption "Enable systemd integration with Hyprland";

    withWaybar = lib.mkEnableOption "Enable and configure waybar";

    monitors = lib.mkOption {
      type = lib.types.submodule {
        options = {
          config = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "DP-3, highrr, auto, 1" # use `hyprctl monitors` to find the display ID
            ];
          };

          appendAutoDisplayConfig = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether to append the monitor configuration line that will auto detect ad-hoc monitors:
              `", preferred, auto, 1"`
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpaper

      # screenshots
      grim
      slurp

      # notifications, required e.g. for discord
      cfg.notificationsPackage

      cfg.fileManagerPackage
      cfg.programMenu.package

      playerctl
      brightnessctl
    ];

    programs.hyprlock.enable = true;

    services.hyprpolkitagent.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      inherit (cfg) package portalPackage;

      systemd.enable = cfg.withSystemd;

      settings = {
        "$mod" = "SUPER";

        "$terminal" = "ghostty";
        "$fileManager" = "${lib.getExe cfg.fileManagerPackage}";
        "$menu" = "${lib.getExe cfg.programMenu.package}";

        monitor =
          cfg.monitors.config
          ++ lib.optionals cfg.monitors.appendAutoDisplayConfig [
            ", preferred, auto, 1" # for ad-hoc monitors, preferred resolution, placed on the right side of main monitor
          ];

        bind = [
          "$mod, Q, killactive"
          "$mod, T, exec, $terminal"
          "$mod, F, exec, $fileManager"
          "$mod, W, exec, firefox"
          "$mod, D, exec, $menu ${cfg.programMenu.runCmd}"
          "$mod, L, exec, hyprlock"
          ", Print, exec, grim -t png -g \"\$(slurp)\" \${HOME}/Pictures/screenshot_\$(date --iso-8601=seconds).png"
          "$mod, Print, exec, grim -t png -g \"\$(slurp)\" - | wl-copy"
          "$mod SHIFT, R, exec, hyprctl reload"

          ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ",XF86MonBrightnessUp, exec, brightnessctl s +10%"

          ",XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"
          ",XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 0.02+"
          ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          ",XF86AudioPlay, exec, playerctl play-pause"
          ",XF86AudioPrev, exec, playerctl previous"
          ",XF86AudioNext, exec, playerctl next"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          )
        );

        exec-once = [
          "waybar"
          "hyprpaper"
          "${lib.getExe cfg.notificationsPackage}"
        ];

        animation = [
          "workspaces, 0"
          "windows, 1, 1, default"
        ];

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 1;
        };

        input = {
          accel_profile = "flat";
          sensitivity = 0;
          # force_no_accel = true; # not recommended in Hyprland docs

          kb_layout = "pl";
        };

      };
    };

    xdg.configFile."hypr/hyprpaper.conf" = {
      enable = true;
      source = ../../dotfiles/hyprpaper.conf;
    };

    programs.waybar = lib.mkIf cfg.withWaybar {
      enable = true;
      settings.main = {
        height = 30;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "wireplumber"
          "battery"
        ];

        clock = {
          format = "{:%H:%M, %F}";
          tooltip-format = "<tt><small>{calendar}</small></tt>"; # needed to display calendar

          timezone = "Europe/Warsaw";

          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };

          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_down";
            on-scroll-down = "shift_up";
          };
        };

        wireplumber = {
          format = "Vol: {volume}% (mic: {format_source})";
          format-muted = "Vol: muted (mic: {format_source})";
          format-source = "{volume}%";
          format-source-muted = "muted";

          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        battery = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          max-length = 25;
        };

      };
    };
  };

}
