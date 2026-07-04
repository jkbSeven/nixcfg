{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./modules/hyprland.nix
  ];

  home.username = "jkb";
  home.homeDirectory = "/home/jkb";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    zsh
    git
    bat
    tmux
    fzf
    jq
    fd
    ripgrep

    # obsidian - fails to run as expects opengl drivers in the Nix-used /run/opengl_..., but they are installed with pacman
    nerd-fonts.ubuntu-mono

    brightnessctl
    discord
    spotify
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) (
      map lib.getName [
        pkgs.obsidian
        pkgs.discord
        pkgs.spotify
      ]
    );

  home.file."${config.xdg.configHome}/tmux/tmux.conf".source = ./dotfiles/tmux.conf;

  home.file.".local/bin" = {
    source = ./dotfiles/bin;
    recursive = true;
  };

  programs.zsh = {
    enable = true;

    setOptions = [
      "vi" # vim motions in the terminal
    ];

    shellAliases = {
      gs = "git status";
      vim = "nvim";
      icat = "kitten icat --fit=both"; # requires kitty terminal
    };

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "robbyrussell";
  };

  programs.git = {
    enable = true;
    settings.user.name = "jkbSeven";
    settings.user.email = "Jacob202@protonmail.com";
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "UbuntuMono Nerd Font";
      size = 16;
    };
  };

  home.pointerCursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 32;
  };

  programs.neovim = {
    enable = true;
    sideloadInitLua = true;

    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    # extraLuaPackages = ps: [ ps.magick ];

    extraPackages = with pkgs; [
      imagemagick
      lua-language-server
      pyright
      nil
    ];
  };

  programs.obsidian.enable = true;
}
