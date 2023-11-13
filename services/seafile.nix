{ ... }:

{
  # seafile
  virtualisation.oci-containers.containers = {
    seafile = {
      image = "seafileltd/seafile:latest";
      ports = [ "8080:80" ];
      volumes = [ "/srv/seafile:/shared" ];
      autoStart = true;
      environment = {
        SEAFILE_SERVER_HOSTNAME = "vivaldi.fritz.box";
        SEAFILE_ADMIN_EMAIL = "matthias.wuensch@proton.me";
        SEAFILE_ADMIN_PASSWORD = "password123";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
