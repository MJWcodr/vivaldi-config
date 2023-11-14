{
virtualisation.oci-containers.containers = {
	"homer" = {
		image = "b4bz/homer:latest";
		volumes = ["/etc/nixos/services/homer/:/www/assets:ro"];
		autoStart = true;
		ports = [ "80:8080" ];
	};
};

services.nginx = {
	enable = true;
	virtualHosts."vivaldi.mjwcodr.de" = {
		locations."/".proxyPass = "http://vivaldi.fritz.box:80";
	};
};

networking.firewall.allowedTCPPorts = [ 80 ];
}
