{
  config,
  lib,
  ...
}:

let
  cfg = config.personal.programs.git;
in
{
  options.personal.programs.git = {
    enable = lib.mkEnableOption "Enable git";

    username = lib.mkOption {
      type = lib.types.str;
      default = "jkbSeven";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "Jacob202@protonmail.com";
    };

    extraAttrs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings.user.name = cfg.username;
      settings.user.email = cfg.email;
    }
    // cfg.extraAttrs;

    personal.shell.aliases = {
      gs = "git status";
    };
  };
}
