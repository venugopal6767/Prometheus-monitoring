#!/bin/bash
set -e

# Variables
NODE_EXPORTER_VERSION="1.7.0"
INSTALL_DIR="/opt"
NODE_USER="node_exporter"

# Update system
sudo apt update
sudo apt install -y wget

# Create a dedicated user
sudo useradd --no-create-home --shell /bin/false $NODE_USER

# Download Node Exporter
cd $INSTALL_DIR
sudo wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract
sudo tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
sudo chown -R $NODE_USER:$NODE_USER node_exporter

# Create systemd service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$NODE_USER
Group=$NODE_USER
Type=simple
ExecStart=$INSTALL_DIR/node_exporter/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "Node Exporter installed and running on port 9100"
echo "Verify: curl http://<App-VM-IP>:9100/metrics"
