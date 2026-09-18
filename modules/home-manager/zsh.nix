{
  config,
  lib,
  ...
}:

let
  cfg = config.personal.programs.zsh;
in
{
  options.personal.programs.zsh = {
    enable = lib.mkEnableOption "Provision zsh shell";

    enableVimMotions = lib.mkEnableOption "Use vim motions instead of default emacs motions";

    oh-my-zsh = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Use oh-my-zsh module";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      setOptions = lib.optionals cfg.enableVimMotions [ "vi" ];

      shellAliases = config.personal.shell.aliases;

      sessionVariables = config.personal.shell.variables;

      oh-my-zsh = lib.mkIf cfg.oh-my-zsh.enable {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };
  };
}
