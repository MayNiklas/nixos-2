{ lib, config, pkgs, ... }:
let

in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  luksab = {
    suckless.enable = true;
    services.dunst.enable = true;
    #programs.vim.enable = true;
    programs.vscode.enable = true;
  };

  # programs.obs-studio = {
  #   enable = true;
  #   package =
  #     pkgs.wrapOBS { plugins = with pkgs.obs-studio-plugins; [ obs-ndi ]; };
  #   plugins = with pkgs.obs-studio-plugins; [ obs-ndi ];
  # };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lukas";
  home.homeDirectory = "/home/lukas";

  xsession.enable = true;
  xsession.windowManager.command = "dwm";
  services.unclutter = {
    enable = true;
    timeout = 5;
  };
  #xsession.scriptPath = ".hm-xsession";

  # Allow "unfree" licenced packages
  nixpkgs.config = { allowUnfree = true; };

  # Install these packages for my user
  home.packages = with pkgs; [
    libnotify
    discord
    brightnessctl
    htop
    multimc

    dolphin
    filezilla
    gcc
    gnome3.dconf
    gparted
    iperf3
    nmap
    signal-desktop
    unzip
    vim
    vlc
    youtube-dl
    zoom-us

    jdk
  ];

  luksab.x86.enable = config.luksab.arch == "x86_64";

  # Imports
  imports = [
    #./modules/devolopment
    #./modules/git
    #./modules/gtk
    ../modules/options
    ./modules/suckless
    ./modules/dunst
    ./modules/zsh
    ./modules/vscode
    ./modules/x86
  ];

  services.gnome-keyring = { enable = true; };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
