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

# Fetch node IPs from metadata and save to file
aws ssm get-parameter --name "node_ips" --with-decryption --query "Parameter.Value" --output text --region "${region}" > $HOME/ips.txt

# Get docker credentials
DOCKER_USERNAME=$(aws ssm get-parameter --name "docker_username" --with-decryption --query "Parameter.Value" --output text --region "${region}")
DOCKER_PASSWORD=$(aws ssm get-parameter --name "docker_password" --with-decryption --query "Parameter.Value" --output text --region "${region}")

# Login to Docker
echo $DOCKER_PASSWORD | sudo docker login --username $DOCKER_USERNAME --password-stdin

# Prune existing load-balancer container
CONTAINER_NAME="load-balancer"
container_ids=$(docker ps -a --filter "name=$CONTAINER_NAME" -q)
if [ -z "$container_ids" ]; then
    echo "No containers '$CONTAINER_NAME' found."
else
    docker stop $container_ids
    docker rm $container_ids
fi

# Run the container
sudo docker run -d -p 5000:5000 --name load-balancer -v $HOME/ips.txt:/app/ips.txt --restart on-failure originresearch/infernet-lb:0.0.1
sudo docker logout
EOF

# Add the script to cron to run at reboot
chmod +x $HOME/run_on_reboot.sh
(crontab -l 2>/dev/null; echo "@reboot $HOME/run_on_reboot.sh") | crontab -

# Execute script for initial setup
$HOME/run_on_reboot.sh
