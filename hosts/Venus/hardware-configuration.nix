# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/de23ffa5-42c8-47c3-8907-af301f0e5243";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-86d1784e-a2cc-4931-9bf7-e36af500239f".device = "/dev/disk/by-uuid/86d1784e-a2cc-4931-9bf7-e36af500239f";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/82D8-180D";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/821ede64-b18b-4de4-8da9-83f8080e012b";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
