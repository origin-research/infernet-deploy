#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce
sudo apt install -y awscli

# Clone deploy repo on the first run
export REPO_PATH=~/repo
if [ ! -d "$REPO_PATH" ]; then
    git clone -b "${repo_branch}" "${repo_url}" "$REPO_PATH"
else
    echo "Repository already exists at $REPO_PATH"
fi

# Config file
cd "$REPO_PATH"
aws ssm get-parameter --name "config_${node_id}" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > config.json
chmod 600 config.json

# Fetch secrets from SSM Parameter Store
DOCKER_USERNAME=$(aws ssm get-parameter --name "docker_username" --with-decryption --query "Parameter.Value" --output text --region "${region}")
DOCKER_PASSWORD=$(aws ssm get-parameter --name "docker_password" --with-decryption --query "Parameter.Value" --output text --region "${region}")

# Run docker compose
echo $DOCKER_PASSWORD | sudo docker login --username $DOCKER_USERNAME --password-stdin
sudo docker compose up -d
sudo docker logout
