let
  matthias = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwkwN92YhNDGtaYbNq9747bMCRVtb2g+w50BOnewCvY";
  matthiasrsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCow7KnyMQO/WGYfyNAIVUf+KAK+Bk4OLxhwPrRjZom+KhADGjFvYn7dVzBh51/zPkd3BReuW8rpC6eyVDkX7rItOD9d32m2ozW/W5/h3UrSmpyo5DaqmPlXn9+TmLFENWWDXmqImRRlEb9Ts4md54d8cJVTF/Rolxi3y4dxALwnIKzPxorJ61rQEr04izdCo84c3NH+Q5fuu2NLgSJxnhLZTz+/DSexpmK7K9Mw23z73e1hRY68pi3/tQPQdVX0YGM2AHyubryrgbhEDzig6CAiHKEvWpc7hKeha/LYYiq9Rs/J1Nui1e/lcxLDz+lgNBMooiwvdrB3WIeVSjIVhx/wrT5YeYPKCWvPdPRZ5wZ3cPk76yB/I2AacHZEWqSXhS88wIdmuEcTAKDLP3HHUWYWpbY4JiaTFHtba4UpIkSd7wW5BY3HIupHLEwHMR7jemenak3ueQtsrCExeO3axD0VL4/xL/PgJPdZm8HsUsn+oJnz5cRBtv2a2gsmAcoPVc=";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7iwA1DTPIsyLbHeFFnC9wa/Sd/np54NVgTFaKHoNFf";
in
{
	# Backup Keys
  "secrets/rclone_backup.age".publicKeys = [ system matthias ];
  "secrets/restic_backup.age".publicKeys = [ system matthias ];
  "secrets/postgrespass.age".publicKeys = [ system matthias ];

	# SSl Keys
  "secrets/sslcert.crt.age".publicKeys = [ system matthias ];
  "secrets/sslcert.key.age".publicKeys = [ system matthias ];
  "secrets/sslroot.crt.age".publicKeys = [ system matthias ];

	# Drone Keys
  "secrets/drone-server.age".publicKeys = [ system matthias ];
	"secrets/gitea-actions-token.age".publicKeys = [ system matthias ];

	# Nextcloud Keys
	"secrets/nextcloud-secrets.age".publicKeys = [ system matthias ];
	"secrets/nextcloud-dbpass.age".publicKeys = [ system matthias ];
	"secrets/nextcloud-adminpass.age".publicKeys = [ system matthias ];

	# Paperless
	"secrets/paperless.age".publicKeys = [ system matthias ];

	# Music Downloader
	"secrets/music-downloader-env.age".publicKeys = [ system matthias ];

	# Radicale
	"secrets/radicale-auth.age".publicKeys = [ system matthias ];

	# FreshRSS 
	"secrets/freshrss.age".publicKeys = [ system matthias ];
}
