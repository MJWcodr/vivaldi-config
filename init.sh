#! /usr/bin/env nix-shell
#! nix-shell --pure -i bash -p curl jq openssh hcloud gum rsync

LOCATION="nbg1"
SIZE="cx32"
INIT_IMAGE="debian-11"
NAME="vivaldi-test"

TEMP_DIR="$(mktemp -d)"
cp -r ./ "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

# Delete Temp Dir on Exit
trap 'rm -rf $TEMP_DIR' EXIT

USE_SSH_ED25519=1

# Check if USE_SSH_ED25519 is set
# If not, use RSA
if [ -z "$USE_SSH_ED25519" ]; then
	gum log "Using RSA"
	SSH_KEY_PATH=~/.ssh/id_rsa
	SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
	SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
else
	gum log "Using ED25519"
	SSH_KEY_PATH=~/.ssh/id_ed25519
	SSH_PUBLIC_KEY="$(cat ~/.ssh/id_ed25519.pub)"
	SSH_PRIVATE_KEY="$(cat ~/.ssh/id_ed25519)"
fi

echo "$SSH_PUBLIC_KEY" > ./id_rsa.pub
echo "$SSH_PRIVATE_KEY" > ./id_rsa

chmod 600 ./id_rsa
chmod 600 ./id_rsa.pub

function waitforssh() {
	until ssh -i ./id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@"$IP" "echo 2>&1"; do
		sleep 1
	done
}

# Check if SSH Key exists

gum format "# Checking if SSH Key exists"
hcloud ssh-key describe vivaldi | grep "$SSH_PUBLIC_KEY" || exit 1

# Initialize Hetzner Server
gum format "# Creating Hetzner Server"
hcloud server create --image $INIT_IMAGE --name $NAME --type $SIZE --ssh-key "vivaldi" --location $LOCATION > /dev/null

# Get IP Address
IP=$(hcloud server list | grep "$NAME" | awk '{print $4}')

# Wait for SSH
gum log "Waiting for SSH"
waitforssh

# Trust SSH
ssh-keyscan -H "$IP" >> ./known_hosts
cat ./known_hosts

# Wait for SSH
gum spin "Waiting for SSH" waitforssh

# Run Nixos Infect
ssh -o "UserKnownHostsFile=./known_hosts" -i ./id_rsa root@"$IP" 'bash -s' < ./nixos-infect.sh

# Push Config to Server
gum format "# Pushing Config to Server"

# copy files to server using rsync
rsync -avz -e "ssh -i ./id_rsa -o UserKnownHostsFile=./known_hosts" ./ root@"$IP":/root/

# copy nixos configuration to server
rsync -avz -e "ssh -i ./id_rsa -o UserKnownHostsFile=./known_hosts" ./ root@"$IP":/etc/nixos/

# Run Nixos Rebuild
gum format "# Rebuiding Nixos Configuration"
ssh -o "UserKnownHostsFile=./known_hosts" -i ./id_rsa root@"$IP" 'nixos-rebuild switch'
