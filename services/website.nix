{
	config, pkgs, ... }:

let 
	port = 8000;
	website = import ./website/default.nix { inherit pkgs; };
in
{
services = {
		nginx = {
			enable = true;
			virtualHosts = {
				"website" = {
					enableACME = false;
					locations = {
						"/" = {
							root = "${website}";
							index = "index.html";
						};
					};
					listen = [ {
						port = port;
						ssl = false;
						addr = "localhost";
					} 
					{
						port = port;
						ssl = false;
						addr = "vivaldi.fritz.box";
					} 
					];
				};
			};
		};
	};

	networking.firewall.allowedTCPPorts = [ 8000 ];
}
