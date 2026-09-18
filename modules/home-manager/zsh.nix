{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.personal.programs.zsh;
in
{
  options.personal.programs.zsh = {
    enable = lib.mkEnableOption "Provision zsh shell";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zsh;
    };

    enableVimMotions = lib.mkEnableOption "Use vim motions instead of default emacs motions";

    oh-my-zsh = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Use oh-my-zsh module";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.oh-my-zsh;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      inherit (cfg) package;

      setOptions = [ ] ++ lib.optionals cfg.enableVimMotions [ "vi" ];

      shellAliases = {
        vim = "nvim";
      }
      // config.personal.shell.aliases;

      sessionVariables = {
        EDITOR = "nvim";
      }
      // config.personal.shell.variables;

      oh-my-zsh = lib.mkIf cfg.oh-my-zsh.enable {
        enable = true;
        inherit (cfg.oh-my-zsh) package;

        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };
  };
}
