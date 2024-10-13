{ pkgs, config, ... }:

{
  system.activationScripts.hass =
    "	${pkgs.coreutils}/bin/mkdir -p /var/lib/hass\n	${pkgs.coreutils}/bin/chown -R 1000:1000 /var/lib/hass\n";

  ####################
  # Home Assistant
  ####################

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/var/lib/hass/:/config" ];
      ports = [ "8123:8123" ];
      environment.TZ = "Europe/Berlin";
      image =
        "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [
        "--network=host"
        # "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
