{ pkgs, ... }:

{

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  users.users.matthias = {
    packages = with pkgs; [
      keepassxc
      firefox
      # gnome
      gnome3.gnome-tweaks
      gnome3.gnome-control-center
      gnome3.gnome-terminal
      gnome3.gnome-calculator

      shotwell
    ];
  };
}
