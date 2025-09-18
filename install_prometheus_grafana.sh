#!/bin/bash
set -e

# Variables
PROM_VERSION="2.49.0"
GRAFANA_VERSION="10.0.1"
INSTALL_DIR="/opt"
PROM_USER="prometheus"
GRAFANA_USER="grafana"

# Update packages
sudo apt update
sudo apt install -y wget tar curl

# -------------------------------
# Install Prometheus
# -------------------------------
sudo useradd --no-create-home --shell /bin/false $PROM_USER

cd $INSTALL_DIR
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xvfz prometheus-${PROM_VERSION}.linux-amd64.tar.gz
sudo mv prometheus-${PROM_VERSION}.linux-amd64 prometheus
sudo chown -R $PROM_USER:$PROM_USER prometheus

# Prometheus systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$PROM_USER
Group=$PROM_USER
Type=simple
ExecStart=$INSTALL_DIR/prometheus/prometheus \\
  --config.file=$INSTALL_DIR/prometheus/prometheus.yml \\
  --storage.tsdb.path=$INSTALL_DIR/prometheus/data

[Install]
WantedBy=multi-user.target
EOF

# Create data directory
sudo mkdir -p $INSTALL_DIR/prometheus/data
sudo chown -R $PROM_USER:$PROM_USER $INSTALL_DIR/prometheus/data

# Reload systemd and start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# -------------------------------
# Install Grafana
# -------------------------------
# Add Grafana APT repo
sudo apt install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt update
sudo apt install -y grafana=$GRAFANA_VERSION

# Enable Grafana service
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# -------------------------------
# Status
# -------------------------------
echo "Prometheus and Grafana installation completed."
echo "Prometheus: http://<VM-IP>:9090"
echo "Grafana: http://<VM-IP>:3000 (default user: admin / password: admin)"
