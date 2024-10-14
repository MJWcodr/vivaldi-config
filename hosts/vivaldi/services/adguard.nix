{ pkgs, config, ...}:
let
	adGuardPort = 4500;
in
{
	# services.adguardhome = {
	# enable = false;
	#	mutableSettings = false;
	#	settings = {
	#		bind_port = adGuardPort;
	#		bind_host = "vivaldi.fritz.box";
	#		dns.bootstrap_dns = [
	#		];
	#	};
	# };

	# networking.firewall.allowedTCPPorts = [ 10000 ];
}
