# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    ./hardware-configuration.nix
    ../common.nix
  ];

  microsoft-surface = {
    surface-control.enable = true;
    ipts.enable = true;
  };

  hardware.opengl = {
    extraPackages = with pkgs; [
      vulkan-validation-layers
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver = {
    videoDrivers = ["nvidia"];
  };

  environment.localBinInPath = true;

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
      };
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
    adb.enable = true;
    dconf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [tkinter]))
    virt-manager
    vulkan-extension-layer
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  services.localtimed.enable = true;

  console.useXkbConfig = true;

  # TODO: Set your hostname
  networking.hostName = "Nomad";

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    extraConfig = ''
      user="maya"
    '';
    qemu.ovmf.enable = true;
    qemu.package = pkgs.qemu_kvm;
    qemu.runAsRoot = true;
  };

  # TODO: This is just an example, be sure to use whatever bootloader you prefer
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
   # replace with hw-conf.nix boot.initrd.luks.devices."luks-9e671905-ffa2-4533-b57d-3c7563bd48c9".device = "/dev/disk/by-uuid/9e671905-ffa2-4533-b57d-3c7563bd48c9";
  # secure boot shit
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.bootspec.enable = true;

  # enable networking
  networking.networkmanager = {
    wifi.backend = "iwd";
  };

  # Set a time zone, idiot
  time.timeZone = "Australia/Perth";

  # Fun internationalisation stuffs (AAAAAAAA)

  i18n.supportedLocales = [
    "en_AU.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # define user acc
  users.users.maya = {
    isNormalUser = true;
    description = "maya";
    extraGroups = ["networkmanager" "wheel" "adbusers" "libvirtd" "surface-control"];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh.settings = {
    enable = false;
    # Forbid root login through SSH.
    permitRootLogin = "yes";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    passwordAuthentication = false;
  };
}