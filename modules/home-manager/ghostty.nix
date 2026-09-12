{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.personal.programs.ghostty;
in
{
  options.personal.programs.ghostty = {
    enable = lib.mkEnableOption "Enable ghostty terminal emulator and provision the configuration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 18;
    };

    fontPkg = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nerd-fonts.ubuntu-mono;
    };

    fontFamily = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = if cfg.fontPkg == pkgs.nerd-fonts.ubuntu-mono then "UbuntuMono Nerd Font" else "";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      default = "Abernathy";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      inherit (cfg) package;
      settings = {
        font-family = cfg.fontFamily;
        font-size = cfg.fontSize;
        theme = cfg.theme;
      };
    };

    home.packages = [ cfg.fontPkg ];
  };
}
