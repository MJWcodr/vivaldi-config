{ ... }:

{
  # Dashy docker service
  virtualisation.oci-containers.containers = {
    dashy = {
      image = "lissy93/dashy:latest";
      ports = [ "8080:80" ];
      environment = { TZ = "Europe/Berlin"; };
      volumes = [ "/etc/nixos/services/dashy/config.yml:/app/public/conf.yml" ];
    };
  };
}
