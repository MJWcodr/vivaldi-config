{
virtualisation.oci-containers.containers = {
	"homer" = {
		image = "b4bz/homer:latest";
		volumes = ["/etc/nixos/services/homer/:/www/assets:ro"];
		autoStart = true;
		ports = [ "80:8080" ];
	};
};

networking.firewall.allowedTCPPorts = [ 80 ];
}
