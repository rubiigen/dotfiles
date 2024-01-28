{
  pkgs,
  outputs,
  lib,
  ...
}: {
  imports = [
    ../../common/arrpc.nix
    ../../common/packages.nix # home.packages and similar stuff
    ../../common/programs.nix # programs.<programName>.enable
    ../../common/gita.nix
  ];

  home = {
    username = "alyx";
    homeDirectory = "/home/alyx";
    file.".config/sway/config".source = ./config;
    file.".config/lockonsleep/config.sh".source = ./lock;
    file.".config/alacritty/alacritty.toml".source = ../../common/alacritty.toml;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
  };

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  systemd.user.targets.sway-session = {
    Unit = {
      Description = "Sway compositor session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };    

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = import ./hyprland.nix;
  };

  programs.waybar = {
    enable = true;
    settings = import ../../common/waybar.nix;
    style = import ../../common/waybar-style.nix;
  };

  services.udiskie.enable = true;

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  # Nicely reload system(d) units when changing configs
  systemd.user.startServices = lib.mkDefault "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
