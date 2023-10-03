# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver = {
    enable = true;
    dpi = 200;
    displayManager.sddm.enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    layout = "us";
    xkbVariant = "colemak";  
    videoDrivers = lib.mkForce [ "nvidia" ];
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };

  environment.pathsToLink = [ "/libexec" ];

  hardware.nvidia = {
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    modesetting.enable = true;
    forceFullCompositionPipeline = true;
  };

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };

  specialisation = {
    clamshell.configuration = {
       system.nixos.tags = [ "clamshell" ];
       boot.kernelParams = [ "module_blacklist=i915" ];
       environment.sessionVariables = {
	 GDK_SCALE = lib.mkForce "1";
         GDK_DPI_SCALE = lib.mkForce "1";
         WLR_NO_HARDWARE_CURSORS = "1";
       };
       environment.variables = {
	 XCURSOR_SIZE = lib.mkForce "24";
       };
       services.xserver.dpi = lib.mkForce 100;
       services.logind = {
         lidSwitch = "ignore";
       };
       hardware.nvidia = {
         powerManagement.enable = lib.mkForce false;
         powerManagement.finegrained = lib.mkForce false;
         prime.offload.enable = lib.mkForce false;
         prime.offload.enableOffloadCmd = lib.mkForce false;
         prime.sync.enable = lib.mkForce true;
       };
    };
  };

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # the configuration (pain)
  programs = {
    #hyprland = {
	#enable = true;
	#xwayland.enable = true;
        #enableNvidiaPatches = true;
    #};
    steam.enable = true;
    #sway = {
      #enable = true;
      #wrapperFeatures.gtk = true;
      #extraOptions = [
        #"--unsupported-gpu"
      #];
    #};
    nm-applet.enable = true;
    adb.enable = true;
    dconf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    logitech-udev-rules
    #wmenu
    xdg-utils
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    bemenu
    wdisplays
    polybar
    xss-lock
    nitrogen
    virt-manager
    wvkbd
    solaar
    swayidle
    gtklock
    maim
    xclip
    xdotool
    (pkgs.python3.withPackages(ps: with ps; [ tkinter ]))
    temurin-jre-bin-8
    temurin-bin-18
    font-awesome
    blueman
    bluez
    bluez-alsa
    swaynotificationcenter
    dunst
    polkit_gnome
    jetbrains-mono
    udiskie
    cinnamon.nemo
    libsForQt5.ark
    lshw
  ];

  environment.sessionVariables = {
    GDK_DPI_SCALE = "0.5";
    GDK_SCALE = "2";
    #WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.variables = {
    XCURSOR_SIZE = "64";
    #WLR_NO_HARDWARE_CURSORS = "1";
  };

  xdg.portal = {
      enable = false;
      wlr.enable = false;
      #extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";

  fonts.packages = with pkgs; [
	font-awesome
	jetbrains-mono
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fwupd.enable = true;
  # TODO: Set your hostname
  networking.hostName = "Messier";

  virtualisation.libvirtd.enable = true;

  # TODO: This is just an example, be sure to use whatever bootloader you prefer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/";
  boot.supportedFilesystems = [ "exfat" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "acpi_rev_override" "intel_iommu=igfx_off" "nvidia_drm.modeset=1" "ibt=off" ]; # if we ever stop using internal panel, blacklist i915
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # enable networking
  networking.networkmanager.enable = true;

  services.dbus.enable = true;

  # Set a time zone, idiot
  time.timeZone = "Europe/London";

  # Fun internationalisation stuffs (AAAAAAAA)
  i18n.defaultLocale = "it_IT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };

  # udisks
  services.udisks2.enable = true;
  # Would you like to be able to fucking print?
  services.printing.enable = true;

  # Sound (kill me now)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.polkit.enable = true;

 systemd = {
  user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "hyprland-session.target" ];
    wants = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
  };
};

  services.lvm.enable = true;

  # define user acc
  users.users.radisys = {
    isNormalUser = true;
    description = "radisys";
    extraGroups = ["networkmanager" "wheel" "adbusers" "libvirtd"];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh.settings = {
    enable = true;
    # Forbid root login through SSH.
    permitRootLogin = "yes";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    passwordAuthentication = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
