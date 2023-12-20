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

# Create a shell script for subsequent boots
cat << 'EOF' > $HOME/run_on_reboot.sh
#!/bin/bash

# Clone deploy repo on the first run
export REPO_PATH=~/repo
if [ ! -d "$REPO_PATH" ]; then
    git clone "${repo_url}" --branch "${repo_branch}" --single-branch "$REPO_PATH"
else
    echo "Repository already exists at $REPO_PATH"
fi

# Config file
cd "$REPO_PATH"
aws ssm get-parameter --name "config_${node_id}" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > config.json
chmod 600 config.json

# Update config file with redis address
REDIS_ADDRESS=$(aws ssm get-parameter --name "redis_address" --with-decryption --query "Parameter.Value" --output text --region "${region}")
jq --arg redis_host "$REDIS_ADDRESS" '.redis.host = $redis_host' config.json > /tmp/config.json && mv /tmp/config.json config.json

# Get docker credentials
DOCKER_USERNAME=$(aws ssm get-parameter --name "docker_username" --with-decryption --query "Parameter.Value" --output text --region "${region}")
DOCKER_PASSWORD=$(aws ssm get-parameter --name "docker_password" --with-decryption --query "Parameter.Value" --output text --region "${region}")

# Run docker compose
echo $DOCKER_PASSWORD | sudo docker login --username $DOCKER_USERNAME --password-stdin
sudo docker compose up -d
sudo docker logout
EOF

# Add the script to cron to run at reboot
chmod +x $HOME/run_on_reboot.sh
(crontab -l 2>/dev/null; echo "@reboot $HOME/run_on_reboot.sh") | crontab -

# Execute script for initial setup
$HOME/run_on_reboot.sh
