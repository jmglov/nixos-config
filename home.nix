{ config, lib, pkgs, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  pkgsChrome =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";
  pkgsClojure =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";
  pkgsDiscord =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";

  babashka-bin = pkgs.callPackage ./pkgs/babashka-bin { };
in {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    amarok
    aspell
    aspellDicts.en
    awscli
    aws-sam-cli
    babashka-bin
    bind
    discord
    emacsNativeComp
    exiftool
    ffmpeg
    gimp
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jq
    nixfmt
    nodejs
    openjdk17
    pciutils
    ripgrep
    shotcut
    slack
    unzip
    usbutils
    yarn
    zip
    zoom-us

    pkgsChrome.google-chrome
    pkgsClojure.clojure
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export AWS_DEFAULT_REGION=eu-west-1
      export AWS_PROFILE=jmglov
      export JAVA_HOME="${pkgs.openjdk17}"
      export PATH="$HOME/bin:$PATH"
    '';
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
  programs.direnv.enable = true;
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
}
