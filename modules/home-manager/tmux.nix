{
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  cfg = config.personal.programs.tmux;
  sessionizerScript = pkgs.writeShellApplication {
    name = "tmux-sessionizer";
    text = lib.strings.removePrefix "#!/bin/sh\n" (
      builtins.readFile (inputs.dotfilesPath + /.local/bin/tmux-sessionizer)
    );
    runtimeInputs = [ pkgs.fzf ];
    bashOptions = [ ]; # the 'nounset' and 'errexit' options make the script unusable
  };
in
{
  options.personal.programs.tmux = {
    enable = lib.mkEnableOption "Whether to enable tmux";
    withSessionizer = lib.mkEnableOption "Whether to use the tmux-sessionizer script";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.tmux
    ]
    ++ lib.optionals cfg.withSessionizer [ sessionizerScript ];

    xdg.configFile.tmux = {
      source = inputs.dotfilesPath + /tmux.conf;
      target = "tmux/tmux.conf";
    };
  };
}
