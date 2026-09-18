{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../modules/home-manager
  ];

  home.username = "jkb";
  home.homeDirectory = "/home/jkb";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    bat
    jq

    nerd-fonts.ubuntu-mono

    discord
    spotify
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "discord"
      "discord-unwrapped"
      "spotify"
    ];

  personal.programs.zsh = {
    enable = true;
    enableVimMotions = true;
    oh-my-zsh.enable = true;
  };

  personal.programs.git.enable = true;

  personal.programs.tmux = {
    enable = true;
    withSessionizer = true;
  };

  personal.programs.neovim = {
    enable = true;
    setVimAlias = true;
    setEditorEnvVar = true;
  };

  personal.programs.hyprland.enable = true;

  personal.programs.ghostty.enable = true;

  home.pointerCursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  programs.obsidian.enable = true;
}
