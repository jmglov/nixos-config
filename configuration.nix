# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
with import ./jmglov/lib { };
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";

  hostName = import ./hostname.nix;
  validHostNames = [ "alhana" "laurana" ];

  pkgsMullvadVPN =
    mkPkgsMain "2023-12-17" "8a9698b0914775be8a426fe94b83d512571eb06a"
    "sha256:0xn7ix1kk92f16xlvc690jr9kwbmrhg65d47bnrk5370yid5cbri";
  pkgsProtonVPN =
    mkPkgsMain "2023-12-07" "cf53751a16df6ae52eb3be7019aa9c34017e490b"
    "sha256:0sz5p63j83a961mjykssn7x2gb23ngfrn3dkdjmkw79iazq42xb1";
in lib.recursiveUpdate {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./jmglov/overlays { inherit pkgs hostName; };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.root = {
    name = "root";
    device = if hostName == "alhana" then
      "/dev/disk/by-uuid/745fb9ef-5747-49cb-bc7c-b143cd1d8983" # blkid /dev/nvme0n1p2
    else
      "/dev/disk/by-uuid/21e8a681-0c2f-409a-bc23-a77cb91ad83b"; # blkid /dev/sda2

    preLVM = true;
    allowDiscards = true;
  };

  networking.hostName = hostName;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Use NetworkManager instead of wpa_supplicant
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # For wpa_supplicant, uncomment:
  #  networking.wireless.enable = true;
  #  networking.wireless.interfaces = [ if hostName == "alhana" then "wlp0s20fs" else "wlp6s0" ];
  #  networking.wireless.networks = {
  #    jmglov = {
  #      # Generated with: wpa_passphrase ESSID PSK
  #      pskRaw = "d4e0bb97d0a451084182ee7193331b273a4fc12de0b5afd7e50f52f0212b1acd";
  #    };
  #  };
  #  networking.wireless.userControlled.enable = true;
  #  networking.wireless.userControlled.group = "wheel";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IE.UTF-8";
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # picom is a standalone compositor for Xorg, suitable for use with window
  # managers that do not provide compositing. See: https://nixos.wiki/wiki/Picom
  services.picom.enable = true;

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.i3.enable = true;
    displayManager.defaultSession = "xfce+i3";
    layout = "us,bg";
    xkbVariant = ",phonetic";
    xkbOptions = "compose:caps, grp:win_space_toggle, caps:none";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.mutableUsers = false;

  users.users.root.hashedPassword = if hostName == "alhana" then
    "$6$qIbRypB1hH$bEgHr79qEl3r81H.AxGo5rqIEZxcF4tu2swxE0uo/vgnAL7ln4UeZiKyu9Z6dhC7oDfyfcYbvNREGEoR1q/xr1"
  else if hostName == "laurana" then
    "$6$qIbRypB1hH$bEgHr79qEl3r81H.AxGo5rqIEZxcF4tu2swxE0uo/vgnAL7ln4UeZiKyu9Z6dhC7oDfyfcYbvNREGEoR1q/xr1"
  else
    lib.assertOneOf "hostName" hostName validHostNames;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jmglov = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [ "audio" "docker" "jmglov" "networkmanager" "wheel" ];
    # Generated with: mkpasswd -m sha-512
    hashedPassword = if hostName == "alhana" then
      "$6$JP.Us63iVh2VH59v$dNcJDA2N9MwRQ1FUtB4vEbEhMbYe8ukEwxejthLO9VJf4c9dzm0vUAJdcTd08Cch3mcr8A.WxhARkdYtKFLpp/"
    else if hostName == "laurana" then
      "$6$H9mwiz7dAfx$5x8LZ.CCddKuBMGrHCTH7r.5T2uGf.b1s51MT.T7MI02KYmWjQ22yrfixyRkcSpFUqoam1OiDcdprrdAMCMir."
    else
      lib.assertOneOf "hostName" hostName validHostNames;
  };

  users.groups.jmglov.gid = 1002;

  home-manager.users.jmglov = import ./jmglov/home.nix {
    inherit config pkgs hostName;
    lib = pkgs.lib;
  };

  security.sudo.extraConfig = ''
    Defaults  lecture="never"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    docker
    git
    mkpasswd
    parted
    steam-run-native
    steamcmd
    vim
    wget
    xfce.xfce4-terminal

    mullvad-vpn
    # pkgsMullvadVPN.mullvad-vpn  ## Latest version; not working

    pkgsProtonVPN.protonvpn-gui
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Use JDK17 for all Java stuff
  programs.java = {
    enable = true;
    package = pkgs.openjdk17;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # List services that you want to enable:

  services.mullvad-vpn.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = if hostName == "alhana" then "22.11" else "21.05";

} (if hostName == "alhana" then {
  networking.interfaces.wlp0s20fs.useDHCP = true;
} else if hostName == "laurana" then {
  networking.interfaces.enp7s0.useDHCP = true;
  networking.interfaces.wlp6s0.useDHCP = true;
} else
  { })
