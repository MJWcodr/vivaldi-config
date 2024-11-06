{ config, pkgs, ... }:

let
  internalInterfacePort = 3600;
  exposedInterfacePort = 3601;
  internalDNSPort = 3653;
  exposedDNSPort = 3654;
  domain = "vivaldi.fritz.box";
  serverIP = "192.168.178.10";
in {
  # create folders for pihole if they don't exist
  system.activationScripts.pihole =
    "	mkdir -p /etc/pihole\n	mkdir -p /etc/dnsmasq.d\n";

  virtualisation.oci-containers.containers."pihole" = {
    autoStart = true;
    image = "pihole/pihole:latest";
    volumes = [ "/etc/pihole:/etc/pihole" "/etc/dnsmasq.d:/etc/dnsmasq.d" ];
    ports = [
      "${toString internalDNSPort}:53/udp"
      "${toString internalInterfacePort}:80/tcp"
    ];
    environment = { ServerIP = serverIP; };
    extraOptions = [ "--cap-add=NET_ADMIN" "--dns=127.0.0.1" "--dns=1.1.1.1" ];
  };

  networking.firewall.allowedTCPPorts =
    [ internalInterfacePort exposedInterfacePort ];
}
