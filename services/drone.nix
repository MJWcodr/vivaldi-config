{config, pkgs, ...}:
let
	droneserver = config.users.users.droneserver.name;
in
{

	##########
	# Secrets
	##########
	age.secrets = {
		drone-server = {
			file = ../secrets/drone-server.age;
			owner = "droneserver";
		};
		sslrootcert = {
			file = ../secrets/sslroot.crt.age;
		};
	};

	##########
	# Drone
	##########

	# Add the sslcert to the trusted store
	security.pki.certificateFiles = [ config.age.secrets.sslrootcert.path ];

	users.users.droneserver = {
		name = "droneserver";
		group = droneserver;
		isSystemUser = true;
	};
	users.groups.droneserver = {};
	
	# Drone server
	system.activationScripts.drone-server = {
		text = ''
			mkdir -p /var/lib/drone
			chown droneserver:droneserver /var/lib/drone
		'';
	};

	systemd.services.drone-server = {
		enable = true;
		wantedBy = [ "multi-user.target" ];

		serviceConfig = {
			# Used for secrets
			EnvironmentFile = config.age.secrets.drone-server.path;
			ExecStart = ''
				${pkgs.drone}/bin/drone-server
			'';
			Environment = [
				"DRONE_DATABASE_DRIVER=sqlite3"
				"DRONE_DATABASE_DATASOURCE=/var/lib/drone/drone.sqlite"
				"DRONE_SERVER_PORT=:8031"
				"DRONE_USER_CREATE=username:matthias,admin:true"
				"DRONE_GITEA_SERVER=https://vivaldi.fritz.box:3001"
				"DRONE_SERVER_HOST=vivaldi.fritz.box"
				"DRONE_SERVER_PROTO=https"
				"DRONE_GITEA_REDIRECT_URL=https://vivaldi.fritz.box:3002/login"
				"DRONE_GITEA_SKIP_VERIFY=true"
				# Defined in EnvironmentFile
				# DRONE_GITEA_CLIENT_ID = "";
				# DRONE_GITEA_CLIENT_SECRET = "";
				# DRONE_RPC_SECRET = "";
		#		};
		];
		# can't coerce set to string
			User = "droneserver";
		#	Group = "droneserver";
		};
	};

		services.nginx.virtualHosts."drone-server" = {
		forceSSL = true;
		sslCertificate = config.age.secrets.sslcert.path;
		sslCertificateKey = config.age.secrets.sslkey.path;

		listen = [ {
			ssl = true;
			port = 3002;
			addr = "vivaldi.fritz.box";
		} ];

		locations."/" = {
			proxyPass = "http://localhost:8031/";
		};
	};

	networking.firewall.allowedTCPPorts = [ 3002 ];
}

