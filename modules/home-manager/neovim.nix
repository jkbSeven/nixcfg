{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.personal.programs.neovim;
in
{
  options.personal.programs.neovim = {
    enable = lib.mkEnableOption "Whether to enable neovim";
    setVimAlias = lib.mkEnableOption "Whether to alias vim to nvim";
    setEditorEnvVar = lib.mkEnableOption "Whether to set EDITOR = nvim shell variable";

    lspPkgs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.lua-language-server
        pkgs.pyright
        pkgs.nil
      ];
    };

    extraAttrs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      sideloadInitLua = true;

      withNodeJs = false;
      withPython3 = false;
      withRuby = false;

      extraPackages = [
        pkgs.fd
        pkgs.ripgrep
      ]
      ++ cfg.lspPkgs;
    }
    // cfg.extraAttrs;

    personal.shell.aliases = lib.mkIf cfg.setVimAlias {
      vim = "nvim";
    };

    personal.shell.variables = lib.mkIf cfg.setEditorEnvVar {
      EDITOR = "nvim";
    };
  };
}
