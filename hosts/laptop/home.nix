{
  pkgs,
  lib,
  ...
}@inputs:

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
    configFile = inputs.dotfilesPath + /tmux.conf;

    sessionizer = {
      enable = true;
      scriptFile = inputs.dotfilesPath + /.local/bin/tmux-sessionizer;
    };
  };

  personal.programs.neovim = {
    enable = true;
    setVimAlias = true;
    setEditorEnvVar = true;
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "robbyrussell";
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
