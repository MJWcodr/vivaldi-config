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
	# Drone-Server
	##########

	# Add the sslcert to the trusted store
	# security.pki.certificateFiles = [ config.age.secrets.sslrootcert.path ];

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
				"DRONE_SERVER_PORT=:3030"
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

	##########
	# Drone-Runner-Docker
	##########

	users.users.drone-runner-docker = {
		name = "drone-runner-docker";
		group = "drone-runner-docker";
		isSystemUser = true;
	};
	users.groups."drone-runner-docker" = {};

	users.users."drone-runner-docker".extraGroups = [ "podman" ];
	
	 systemd.services.drone-runner-docker = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.drone-runner-docker}/bin/drone-runner-docker
    '';
    ### MANUALLY RESTART SERVICE IF CHANGED
    restartIfChanged = false;
    serviceConfig = {
      Environment = [
        "DRONE_RPC_PROTO=http"
        "DRONE_RPC_HOST=localhost:3030"
        "DRONE_RUNNER_CAPACITY=2"
        "DRONE_RUNNER_NAME=drone-runner-docker"
      ];
      EnvironmentFile = config.age.secrets.drone-server.path;
      User = "drone-runner-docker";
      Group = "drone-runner-docker";
    };
  };

	##########
	# Exec Runner
	##########
	
  ### Exec runner

  users.users.drone-runner-exec = {
    isSystemUser = true;
    group = "drone-runner-exec";
  };
  users.groups.drone-runner-exec = { };

  # Allow the exec runner to write to build with nix
  nix.allowedUsers = [ "drone-runner-exec" ];

  systemd.services.drone-runner-exec = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.drone-runner-exec}/bin/drone-runner-exec
    '';
    ### MANUALLY RESTART SERVICE IF CHANGED
    restartIfChanged = true;
    confinement.enable = true;
    confinement.packages = [
      pkgs.git
      pkgs.gnutar
      pkgs.bash
      pkgs.nixFlakes
      pkgs.gzip
    ];
    path = [
      pkgs.git
      pkgs.gnutar
      pkgs.bash
      pkgs.nixFlakes
      pkgs.gzip
    ];
    serviceConfig = {
      Environment = [
        "DRONE_RPC_PROTO=http"
        "DRONE_RPC_HOST=localhost:3030"
        "DRONE_RUNNER_CAPACITY=2"
        "DRONE_RUNNER_NAME=drone-runner-exec"
        "NIX_REMOTE=daemon"
        "PAGER=cat"
        "DRONE_DEBUG=true"
      ];
      BindPaths = [
        "/nix/var/nix/daemon-socket/socket"
        "/run/nscd/socket"
        # "/var/lib/drone"
      ];
      BindReadOnlyPaths = [
        "/etc/passwd:/etc/passwd"
        "/etc/group:/etc/group"
        "/nix/var/nix/profiles/system/etc/nix:/etc/nix"
        "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-certificates.crt"
        "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
        "${builtins.toFile "ssh_config" ''
          Host git.ayats.org
          ForwardAgent yes
        ''}:/etc/ssh/ssh_config"
        "/etc/machine-id"
        "/etc/resolv.conf"
        "/nix/"
				"/etc/nixos"
      ];
      EnvironmentFile = config.age.secrets.drone-server.path;
      User = "drone-runner-exec";
      Group = "drone-runner-exec";
    };
  };


	##########
	# Nginx
	##########

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
			proxyPass = "http://localhost:3030/";
		};
	};

	networking.firewall.allowedTCPPorts = [ 3002 ];
}

