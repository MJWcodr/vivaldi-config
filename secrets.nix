let
	matthias = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwkwN92YhNDGtaYbNq9747bMCRVtb2g+w50BOnewCvY";
	matthiasrsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCow7KnyMQO/WGYfyNAIVUf+KAK+Bk4OLxhwPrRjZom+KhADGjFvYn7dVzBh51/zPkd3BReuW8rpC6eyVDkX7rItOD9d32m2ozW/W5/h3UrSmpyo5DaqmPlXn9+TmLFENWWDXmqImRRlEb9Ts4md54d8cJVTF/Rolxi3y4dxALwnIKzPxorJ61rQEr04izdCo84c3NH+Q5fuu2NLgSJxnhLZTz+/DSexpmK7K9Mw23z73e1hRY68pi3/tQPQdVX0YGM2AHyubryrgbhEDzig6CAiHKEvWpc7hKeha/LYYiq9Rs/J1Nui1e/lcxLDz+lgNBMooiwvdrB3WIeVSjIVhx/wrT5YeYPKCWvPdPRZ5wZ3cPk76yB/I2AacHZEWqSXhS88wIdmuEcTAKDLP3HHUWYWpbY4JiaTFHtba4UpIkSd7wW5BY3HIupHLEwHMR7jemenak3ueQtsrCExeO3axD0VL4/xL/PgJPdZm8HsUsn+oJnz5cRBtv2a2gsmAcoPVc=";
	system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7iwA1DTPIsyLbHeFFnC9wa/Sd/np54NVgTFaKHoNFf";
in
{
	# Backup keys
	"secrets/rclone_backup.age".publicKeys = [ system matthias];
	"secrets/restic_backup.age".publicKeys = [ system matthias];

	# Postgres password
	"secrets/postgrespass.age".publicKeys = [ system matthias];
	# SSL cert for the webserver
	"secrets/sslcert.crt.age".publicKeys = [ system matthias ];
	"secrets/sslcert.key.age".publicKeys = [ system matthias ];

	# Wireguard
	"secrets/wireguard-client-privatekey.age".publicKeys = [ system matthias ];
	"secrets/wireguard-client-publickey.age".publicKeys = [ system matthias ];

	"secrets/wireguard-server-publickey.age".publicKeys = [ system matthias ];

}
