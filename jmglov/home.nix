{ config, lib, pkgs, hostName, ... }:
with import ./lib { };
let
  unstableTarball = builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgsUnstable = import unstableTarball { config.allowUnfree = true; };

  chromePkgs =
    mkPkgsMain "2024-03-13" "a05578f52bae3119017d544f911940d0e6ee475a"
    "sha256:0hmpv93y0h3b9kf7yv2ffzjrxpy1jkviqjjq2yvgwpk1f1azpcwg";

  babashka-bin = pkgs.callPackage ./pkgs/babashka-bin { };
  bbin = pkgs.callPackage ./pkgs/bbin { };
in lib.recursiveUpdate {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    (aspellWithDicts (dicts: with dicts; [ en ]))
    audacity
    awscli
    babashka-bin
    # bbin  # oops, not checked in somehow
    bind
    chromePkgs.brave
    clojure
    discord
    emacsNativeComp
    exiftool
    ffmpeg-full
    fzf
    gimp
    chromePkgs.google-chrome
    htop
    id3v2 # media file metadata
    imagemagick
    #(jetbrains.idea-community.override { jdk = openjdk11; })
    jless
    jq
    kazam # screen recorder
    mplayer
    ncdu
    neil # Clojure deps tool
    nixfmt
    nodejs
    openjdk17
    openshot-qt # video editor
    pciutils
    pinta # MS Paint clone
    qbittorrent
    ripgrep
    rofimoji
    rpi-imager # Raspberry Pi imager
    shfmt
    shellcheck
    shotcut # screetshots
    slack
    tree
    terraform
    unzip
    usbutils
    vorbis-tools
    wordnet # https://docs.doomemacs.org/v21.12/modules/tools/lookup/
    xclip
    yarn
    zip
    zoom-us
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      export AWS_DEFAULT_REGION=eu-west-1
      export AWS_REGION=eu-west-1
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

  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      bars = [{
        hiddenState = "hide";
        mode = "dock";
        statusCommand = "${pkgs.i3status}/bin/i3status";
        trayOutput = "eDP-1";
      }];
      keybindings = lib.mkOptionDefault {
        # Use pactl to adjust volume in PulseAudio.
        "XF86AudioRaiseVolume" =
          "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
        "XF86AudioLowerVolume" =
          "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
        "XF86AudioMute" =
          "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
        "XF86AudioMicMute" =
          "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";
        # Gotta have screenshots!
        "Print" = "exec xfce4-screenshooter -f";
        "Shift+Print" = "exec xfce4-screenshooter -r";
        "Control+Print" = "exec xfce4-screenshooter -w";
        # move workspace to next output (monitor)
        "${modifier}+m" = "move workspace to output next";
        # Exec mode for extra programs
        "${modifier}+Shift+Return" = ''mode "exec"'';
        # Emoji keyboard
        "${modifier}+period" = "exec rofimoji";
        # Lock screen
        "${modifier}+Control+Escape" = "exec i3lock";
        # Show session dialog
        "${modifier}+Shift+e" = "exec xfce4-session-logout";
      };
      modes = lib.mkOptionDefault {
        exec = {
          "a" = "exec audacity";
          "b" = "exec brave";
          "c" = "exec google-chrome-stable";
          "d" = "exec discord";
          "e" = "exec emacs";
          "f" = "exec firefox";
          "g" = "exec gimp";
          "i" = "exec idea-community";
          "k" = "exec kazam";
          "q" = "exec qbittorrent";
          "s" = "exec slack";
          "v" = "exec protonvpn-app";
          "x" = "exec xfce4-settings-manager";
          "z" = "exec zoom";
          # back to normal: Enter or Escape or $mod+r
          "Return" = ''mode "default"'';
          "Escape" = ''mode "default"'';
          "$mod+Shift+Return" = ''mode "default"'';
        };
      };
      modifier = "Mod4";
      terminal = "xfce4-terminal";
      window.border = 0;
    };
    extraConfig = ''
      set $refresh_i3status killall -SIGUSR1 i3status
      # xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
      # screen before suspend. Use loginctl lock-session to lock your screen.
      exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
      # NetworkManager is the most popular way to manage wireless networks on Linux,
      # and nm-applet is a desktop environment-independent system tray GUI for it.
      exec --no-startup-id nm-applet
    '';
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
