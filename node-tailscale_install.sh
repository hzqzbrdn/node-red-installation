#!/bin/bash

# *****************************************************
#   N   N  OOO   DDDD   EEEEE   RRRR    EEEEE   DDDD
#   NN  N O   O  D   D  E       R   R   E       D   D
#   N N N O   O  D   D  EEEE    RRRR    EEEE    D   D
#   N  NN O   O  D   D  E       R  R    E       D   D
#   N   N  OOO   DDDD   EEEEE   R   R   EEEEE   DDDD
#                                                    
#               Script created by: haziq
#       Automating the Node-RED installation process!   
# *****************************************************

# Update system
echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

# Install necessary dependencies
echo "Installing build-essential and python3..."
sudo apt install -y build-essential python3

# Install NVM (Node Version Manager)
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Source NVM for the current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Install Node.js using NVM (Node.js version 18)
echo "Installing Node.js version 18..."
nvm install 18
nvm use 18
nvm alias default 18

# Install Node-RED
echo "Installing Node-RED..."
npm install -g --unsafe-perm node-red

# Install necessary Node-RED nodes (e.g., node-red-node-serialport)
echo "Installing Node-RED nodes..."
MAX_RETRIES=5
RETRY_COUNT=0
SUCCESS=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    npm install --no-audit --no-update-notifier --no-fund --save --save-prefix=~ --omit=dev --engine-strict node-red-node-serialport@2.0.3
    if [ $? -eq 0 ]; then
        SUCCESS=1
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT+1))
    echo "Retrying npm install ($RETRY_COUNT/$MAX_RETRIES)..."
    sleep 5
done

if [ $SUCCESS -eq 0 ]; then
    echo "Failed to install Node-RED nodes after $MAX_RETRIES attempts."
    exit 1
fi

# Create a systemd service for Node-RED
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

# Set permissions and reload systemd
sudo chown -R $USER:$USER /home/$USER/.nvm
sudo systemctl daemon-reload

# Enable Node-RED to start on boot
echo "Enabling Node-RED to start on boot..."
sudo systemctl enable nodered

# Start Node-RED service
echo "Starting Node-RED..."
sudo systemctl start nodered

# Check the status of Node-RED
echo "Checking Node-RED status..."
sudo systemctl status nodered

echo "--------------------NODE-RED INSTALLED!-------------------------------------"
echo "............................................................................."
echo "---------------------INSTALLING TAILSCALE------------------------------------"

# Install Tailscale using a separate script
curl -sSL https://raw.githubusercontent.com/iyon09/Bivocom-Node-RED-Tailscale-/main/DanLab_BV2.sh | bash

echo "--------------------TAILSCALE INSTALLED!------------------------------------"
