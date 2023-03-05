{ config, lib, pkgs, hostName, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  pkgsClojure =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";

  babashka-bin = pkgs.callPackage ./pkgs/babashka-bin { };
  # Not working; probably need to update nixpkgs
  # zoom-us = pkgs.callPackage ./pkgs/zoom-us { };
in {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    awscli
    babashka-bin
    bind
    discord
    emacsNativeComp
    exiftool
    ffmpeg
    fzf
    gimp
    google-chrome
    htop
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jq
    ncdu
    nixfmt
    nodejs
    openjdk17
    pciutils
    pinta
    ripgrep
    rofimoji
    slack
    tree
    unzip
    usbutils
    xclip
    yarn
    zip
    zoom-us

    pkgsClojure.clojure
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export AWS_DEFAULT_REGION=eu-west-1
      export AWS_PROFILE=jmglov
      export JAVA_HOME="${pkgs.openjdk17}"
      export PATH="$HOME/bin:$PATH"
    '' + (if builtins.pathExists ./bashrc-extra.nix then
      import ./bashrc-extra.nix
    else
      "");
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    shellOptions = [
      "checkhash"
      "checkjobs"
      "cmdhist"
      "checkwinsize"
      "extglob"
      "globstar"
      "histappend"
      "lithist"
    ];
  };
  programs.firefox.enable = true;
  programs.home-manager = {
    enable = true;
    path = "...";
  };
  programs.tmux = {
    enable = true;
    prefix = "M-m";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-boot 'on'
          set -g @continuum-restore 'on'
        '';
      }
    ];
  };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 60;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n";
  };
} // (if hostName == "alhana" then {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
} else
  { })
