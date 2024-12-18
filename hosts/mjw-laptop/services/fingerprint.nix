{ config, pkgs, lib, ... }:

{

  services.udev.extraRules = ''
    # Goodix Fingerprint Sensor
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="538c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="538c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="533c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="533c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="530c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="530c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5840", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5840", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
  '';

}
