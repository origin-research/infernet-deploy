#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce

# Clone deploy repo on the first run
export REPO_PATH=~/repo
if [ ! -d "$REPO_PATH" ]; then
    git clone -b "${repo_branch}" "${repo_url}" "$REPO_PATH"
else
    echo "Repository already exists at $REPO_PATH"
fi

# Config file
cd "$REPO_PATH"
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret-config -H "Metadata-Flavor: Google" | base64 --decode > config.json
chmod 600 config.json

# Get docker credentials
export DOCKER_USERNAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_username" -H "Metadata-Flavor: Google")
export DOCKER_PASSWORD=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_password" -H "Metadata-Flavor: Google")

# Run docker compose
echo $DOCKER_PASSWORD | sudo docker login --username $DOCKER_USERNAME --password-stdin
sudo docker compose up -d
sudo docker logout
