#!/bin/bash

echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y


echo "Installing build-essential and python3..."
sudo apt install -y build-essential python3


echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  


echo "Installing Node.js version 18..."
nvm install 18
nvm use 18
nvm alias default 18


echo "Installing Node-RED..."
npm install -g --unsafe-perm node-red


echo "Installing Node-RED nodes..."
npm install --no-audit --no-update-notifier --no-fund --save --save-prefix=~ --omit=dev --engine-strict node-red-node-serialport@2.0.3


echo "Setting up Node-RED systemd service..."

cat <<EOL | sudo tee /etc/systemd/system/nodered.service
[Unit]
Description=Node-RED
Documentation=http://nodered.org
After=network.target

[Service]
ExecStart=/bin/bash -c 'source /home/admin/.nvm/nvm.sh && nvm use 18 && node-red'
User=admin
Group=admin
WorkingDirectory=/home/admin
Restart=on-failure
Environment=NODE_RED_OPTIONS=-v
Environment=PATH=/home/admin/.nvm/versions/node/v18.20.8/bin:$PATH
Environment=HOME=/home/admin
Environment=USER=admin
StandardOutput=journal
StandardError=journal
SyslogIdentifier=node-red

[Install]
WantedBy=multi-user.target
EOL


sudo chown -R admin:admin /home/admin/.nvm
sudo systemctl daemon-reload

echo "Enabling Node-RED to start on boot..."
sudo systemctl enable nodered


echo "Starting Node-RED..."
sudo systemctl start nodered


echo "Checking Node-RED status..."
sudo systemctl status nodered

echo "--------------------NODE-RED INSTALLED!-------------------------------------"
echo "............................................................................."
echo "---------------------INSTALLING TAILSCALE------------------------------------"

curl -sSL https://raw.githubusercontent.com/iyon09/Bivocom-Node-RED-Tailscale-/main/DanLab_BV2.sh | bash

echo "--------------------TAILSCALE INSTALLED!------------------------------------"
