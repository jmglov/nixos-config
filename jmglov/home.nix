{ config, lib, pkgs, hostName, ... }:
with import ./lib { };
let
  chromePkgs =
    mkPkgsMain "2025-05-02" "0a7b04c50f08839b0fd3b4bd60a476de6cbc9ec9"
    "sha256:0c1mnhcrk6pvsgmr24r40hjpmldgdwalqhcvzjxnhzfg3ljqf61x";
  signalPkgs =
    mkPkgsMain "2025-07-18" "24c9f80f7baef47968d9ca156832025b74792921"
    "sha256:181bif07ydjrk2xajssym2hxva30vpdk2cgswkzi16g3ha2jhx7x";

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
    calibre # ebooks
    clojure
    discord
    emacsNativeComp
    exiftool
    ffmpeg-full
    flutter
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
    nix-index
    nixfmt
    nodejs
    openjdk17
    openshot-qt # video editor
    patchelf
    pciutils
    pinta # MS Paint clone
    qbittorrent
    reaper # digital audio workstation
    ripgrep
    rofimoji
    rpi-imager # Raspberry Pi imager
    signalPkgs.signal-desktop
    shfmt
    shellcheck
    shotcut # screetshots
    tree
    terraform
    tor
    unrar
    unzip
    usbutils
    vorbis-tools
    wordnet # https://docs.doomemacs.org/v21.12/modules/tools/lookup/
    xclip
    yarn
    zip
    zoom-us

    # Audacity plugins
    # https://plugins.audacityteam.org/realtime-effects/plugin-suites
    calf
    gxplugins-lv2
    lsp-plugins
    swh_lv2
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
          "s" = "exec signal-desktop";
          "t" = "exec tor";
          "v" = "exec protonvpn-app";
          "x" = "exec xfce4-settings-manager";
          "z" = "exec zoom";
          # back to normal: Enter or Escape or $mod+r
          "Return" = ''mode "default"'';
          "Escape" = ''mode "default"'';
          "$mod+Shift+Return" = ''mode "default"'';
        };

        resize = {
          "Shift+Left" = "resize shrink width 5 px or 5 ppt";
          "Shift+Right" = "resize grow width 5 px or 5 ppt";
          "Shift+Down" = "resize grow height 5 px or 5 ppt";
          "Shift+Up" = "resize shrink width 5 px or 5 ppt";
          "Ctrl+Shift+Left" = "resize shrink width 1 px or 1 ppt";
          "Ctrl+Shift+Right" = "resize grow width 1 px or 1 ppt";
          "Ctrl+Shift+Down" = "resize grow height 1 px or 1 ppt";
          "Ctrl+Shift+Up" = "resize shrink width 1 px or 1 ppt";
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
