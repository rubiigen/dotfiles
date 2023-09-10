{
  pkgs,
  outputs,
  lib,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../../common/packages.nix # home.packages and similar stuff
    ../../common/programs.nix # programs.<programName>.enable
    ../../common/arrpc.nix
  ];

  # TODO: Set your username
  home = {
    username = "rion";
    homeDirectory = "/home/rion";
    file.".config/hypr/hyprpaper.conf".text = ''
      preload = ~/.config/wallpapers/mandelbrot_gap_magenta.png
      wallpaper = DVI-D-1,~/.config/wallpapers/mandelbrot_gap_magenta.png
      wallpaper = DP-3,~/.config/wallpapers/mandelbrot_gap_magenta.png
      wallpaper = HDMI-A-1,~/.config/wallpapers/mandelbrot_gap_magenta.png
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    settings = import ./hyprland.nix;
  };
  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  # Nicely reload system(d) units when changing configs
  systemd.user.startServices = lib.mkDefault "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
