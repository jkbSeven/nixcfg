{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.personal.programs.tmux;
  sessionizerScript = pkgs.writeShellApplication {
    name = "tmux-sessionizer";
    text = lib.strings.removePrefix "#!/bin/sh\n" (builtins.readFile cfg.sessionizer.scriptFile);
    runtimeInputs = [ pkgs.fzf ];
    bashOptions = [ ]; # the 'nounset' and 'errexit' options make the script unusable
  };
in
{
  options.personal.programs.tmux = {
    enable = lib.mkEnableOption "Whether to enable tmux";
    configFile = lib.mkOption {
      type = lib.types.path;
    };

    sessionizer = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Whether to use the tmux-sessionizer script";
          scriptFile = lib.mkOption {
            type = lib.types.path;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.tmux
    ]
    ++ lib.optionals cfg.sessionizer.enable [ sessionizerScript ];

    xdg.configFile.tmux = {
      source = cfg.configFile;
      target = "tmux/tmux.conf";
    };
  };
}
