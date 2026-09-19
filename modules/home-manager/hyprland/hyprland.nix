{
  config,
  pkgs,
  lib,
  ...
}@inputs:
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
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  output = lib.mkOption { type = lib.types.nonEmptyStr; };
                  mode = lib.mkOption { type = lib.types.nonEmptyStr; };
                  position = lib.mkOption { type = lib.types.nonEmptyStr; };
                  scale = lib.mkOption { type = lib.types.int; };
                };
              }
            );
            default = [
              {
                output = "DP-3";
                mode = "highrr";
                position = "auto";
                scale = 1;
              }
            ];
          };

          appendAutoDisplayConfig = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Whether to append the monitor configuration that will configure ad-hoc monitors:
              ```
              hl.monitors({
                output = "",
                mode = "preferred",
                position = "auto",
                scale = 1,
              })
              ```
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

      # required e.g. for discord
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

      configType = "lua";
      extraConfig = builtins.readFile ./hyprland.lua;

      settings = {
        terminal = {
          _var = "ghostty";
        };

        menu = {
          _var = "${lib.getExe cfg.programMenu.package}";
        };

        fileManager = {
          _var = "${lib.getExe cfg.fileManagerPackage}";
        };

        monitor =
          cfg.monitors.config
          ++ lib.optionals cfg.monitors.appendAutoDisplayConfig [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];

        on = {
          _args =
            let
              waybar = if cfg.withWaybar then "  hl.exec_cmd(\"waybar\")\n" else "";
            in
            [
              "hyprland.start"
              (lib.generators.mkLuaInline "function()\n  hl.exec_cmd(\"hyprpaper\")\n  hl.exec_cmd(\"${lib.getExe cfg.notificationsPackage}\")\n${waybar}end")
            ];
        };

        bind = [
          {
            _args = [
              (lib.generators.mkLuaInline "mod .. \" + D\"")
              (lib.generators.mkLuaInline "hl.dsp.exec_cmd(menu .. \" ${cfg.programMenu.runCmd}\")")
            ];
          }
        ];

      };
    };

    xdg.configFile."hypr/hyprpaper.conf" = {
      enable = true;
      source = inputs.dotfilesPath + /hyprpaper.conf;
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
