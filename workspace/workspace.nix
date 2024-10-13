{ pkgs, ... }:

{

  imports = [ ./../services/gnome-remote-desktop.nix ];

  services.gnome3.gnome-remote-desktop.enable = true;

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

      # Steam
      steam
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.opengl.driSupport32Bit =
    true; # Enables support for 32bit libs that steam uses

  # Enable Stadia Controller
  services.udev.extraRules = ''
    # SDP protocol
    KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1fc9", MODE="0666"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", MODE="0666"
    # Flashloader
    KERNEL=="hidraw*", ATTRS{idVendor}=="15a2", MODE="0666"
    # Controller
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="18d1", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="9400", MODE="0660", TAG+="uaccess"
  '';
}
