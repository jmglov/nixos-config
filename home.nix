{ config, lib, pkgs, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  pkgsBabashka =
    mkPkgsMain "2022-06-18" "cb058dc7ea65b3f853672386433ca628a1fced1f"
    "18f97s87f1yvvnv800w0rlwsgsgv4yc3763syw4z5m7kywxqmr4j";
  pkgsChrome =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";
  pkgsClojure =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";
  pkgsDiscord =
    mkPkgsMain "2022-06-12" "914ef51ffa88d9b386c71bdc88bffc5273c08ada"
    "18n30qvl1mp531k0krnkr60jviifh75d21rgbxjnx186lkwi7sh3";
in {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    amarok
    awscli
    aws-sam-cli
    bind
    emacsNativeComp
    ffmpeg
    gimp
    ideogram
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jq
    nixfmt
    nodejs
    openjdk17
    pciutils
    ripgrep
    slack
    unzip
    usbutils
    yarn
    zoom-us

    pkgsBabashka.babashka
    pkgsChrome.google-chrome
    pkgsClojure.clojure
    pkgsDiscord.discord
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

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n";
  };
}
