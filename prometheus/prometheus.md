_prometheus installation_

create the user and folder's to handle the prometheus process itself. So we are aware of user-based processes and permissions.

```bash
sudo useradd --no-create-home -c "Monitoring user" --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

_download the prometheus binary_

```bash
sudo apt install wget tar -y
wget https://github.com/prometheus/prometheus/releases/download/v2.47.2/prometheus-2.47.2.linux-amd64.tar.gz
tar -vxzf prometheus-2.47.2.linux-amd64.tar.gz
mv prometheus-2.47.2.linux-amd64 prometheus-files
```

_permission management_

We should provide the appropriate permissions that are required for all binaries.

```bash
sudo mv prometheus-files/prometheus /usr/local/bin/
sudo mv prometheus-files/promtool /usr/local/bin/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo mv prometheus-files/prometheus.yml /etc/prometheus/
sudo mv prometheus-files/consoles /etc/prometheus
sudo mv prometheus-files/console_libraries /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus  /etc/prometheus/prometheus.yml
```

_prepare the prometheus configuiration yaml file_

For the time being, I am going to add only the prometheus service to monitor prometheus itself.

create the file under this location `/etc/prometheus` with the name of `prometheus.yml` include the below content

```bash
# sudo vim /etc/prometheus/prometheus.yml
global:
  scrape_interval:     15s      # default 1m
  evaluation_interval: 15s      # default 1m
  scrape_timeout: 10s           # default 10s

# # Alertmanager configuration
# alerting:
#   alertmanagers:
#   - static_configs:
#     - targets:
#       - alertmanager:9093

# # Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
# rule_files:
#   - "/etc/prometheus/rules.yml"
#   - "/etc/prometheus/add-rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
      labels: 
        instance: prometheus
```

_custom systemd service_

to supervise the prometheus service We can easily create the systemd service in Linux, and we can be aware of how we can start and stop those binaries.

```service
# sudo vim /etc/systemd/system/prometheus.service 

[Unit]
Description=Prometheus Monitoring service
After=network.target auditd.service

[Service]
Type=simple
WorkingDirectory=/var/lib/prometheus
User=prometheus
ExecStart=/usr/local/bin/prometheus \
 --config.file=/etc/prometheus/prometheus.yml \
 --storage.tsdb.path=/var/lib/prometheus/data/ \
 --web.console.templates=/etc/prometheus/consoles \
 --web.console.libraries=/etc/prometheus/console_libraries \
 --storage.tsdb.retention=30d \
 --web.enable-admin-api \
 --web.external-url=http://localhost:9090 \
 --web.listen-address="0.0.0.0:9090" \
 --log.level=info \
 --web.enable-lifecycle \
 --web.page-title="Prometheus Time Series Collection and Processing Server" \
 --log.format=logfmt

Restart=always
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=default.target
```

_service management_

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl status prometheus
sudo netstat -tulpn | grep 9090
```
