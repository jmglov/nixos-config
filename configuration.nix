# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
  hostName = import ./hostname.nix;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ./jmglov/overlays { inherit pkgs; };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices.root = {
    name = "root";
    device =
      "/dev/disk/by-uuid/745fb9ef-5747-49cb-bc7c-b143cd1d8983"; # blkid /dev/nvme0n1p2
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
  # networking.interfaces.wlp0s20fs.useDHCP = true;

  # Use NetworkManager instead of wpa_supplicant
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  programs.nm-applet.enable = true;

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
    layout = "us";
    xkbOptions = "compose:caps, caps:none";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.mutableUsers = false;

  users.users.root.hashedPassword = import ./root-password.nix;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jmglov = {
    isNormalUser = true;
    uid = 1002;
    extraGroups = [ "audio" "docker" "jmglov" "networkmanager" "wheel" ];
    hashedPassword = import ./jmglov-password.nix;
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
    vim
    wget
    xfce.xfce4-terminal
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

  # List services that you want to enable:
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
