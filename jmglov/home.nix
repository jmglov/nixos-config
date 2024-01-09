{ config, lib, pkgs, hostName, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  babashka-bin = pkgs.callPackage ./pkgs/babashka-bin { };
  bbin = pkgs.callPackage ./pkgs/bbin { };
in lib.recursiveUpdate {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    awscli
    babashka-bin
    bbin
    bind
    brave
    clojure
    discord
    emacsNativeComp
    exiftool
    ffmpeg-full
    fzf
    gimp
    google-chrome
    htop
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jless
    jq
    kazam
    mplayer
    ncdu
    nixfmt
    nodejs
    openjdk17
    pciutils
    pinta
    qbittorrent
    ripgrep
    rofimoji
    rpi-imager
    shfmt
    shellcheck
    shotcut
    slack
    tree
    terraform
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
      export AWS_PROFILE=jmglov
      export JAVA_HOME="${pkgs.openjdk17}"
      export PATH="$HOME/bin:$HOME/.babashka/bin:$PATH"
      export PS1="\n\[\033[1;32m\]\[\e]0;: \w\a\]: \W;\[\033[0m\] "
    '' + (if builtins.pathExists ./bashrc-${hostName}.nix then
      import ./bashrc-${hostName}.nix
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
} (if hostName == "alhana" then {
  home.stateVersion = "22.11";
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
} else if hostName == "laurana" then {
  home.stateVersion = "22.05";
} else
  { })
