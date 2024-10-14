{ config, pkgs, lib, builtins, ... }:
let
  cfg = config.services.fingerprintXPS15;
  fprintdriver = builtins.fetchTarball {
    url = "http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-goodix/libfprint-2-tod1-goodix_0.0.6.orig.tar.gz";
    sha256 = "";
  };
in
{
  options = {
    services.fingerprintXPS15 = {
      enable = lib.mkEnableOption "Enable fingerprint reader support for Dell XPS 15 9500";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      				# Dell XPS 15 9570
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="538c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="538c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="533c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="533c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="530c", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="530c", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5840", ATTRS{dev}=="*", TEST=="power/control", ATTR{power/control}="auto", MODE="0660", GROUP="plugdev"
      				SUBSYSTEM=="usb", ATTRS{idVendor}=="27c6", ATTRS{idProduct}=="5840", ENV{LIBFPRINT_DRIVER}="Goodix Fingerprint Sensor"
      		'';
    system.activationScripts.copyFprintXPS159500Driver = ''
      			mkdir -p /usr/lib/libfprint-2-tod1-goodix
      			tar -xzf ${fprintdriver}/usr/lib/x86_64-linux-gnu/libfrint-2/tod-1/* -C /usr/lib/libfprint-2-tod1-goodix
      			'';
  };

}
