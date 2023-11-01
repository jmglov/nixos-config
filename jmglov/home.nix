{ config, lib, pkgs, hostName, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  babashka-bin = pkgs.callPackage ./pkgs/babashka-bin { };
in lib.recursiveUpdate {
  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    awscli
    babashka-bin
    bind
    clojure
    discord
    emacsNativeComp
    exiftool
    ffmpeg
    fzf
    gimp
    google-chrome
    htop
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jless
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
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export AWS_DEFAULT_REGION=eu-west-1
      export AWS_PROFILE=pitch-dev
      export JAVA_HOME="${pkgs.openjdk17}"
      export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
      export PATH="$HOME/bin:$HOME/.npm-packages/bin:$PATH"
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
} (if hostName == "alhana" then {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
} else
  { })
