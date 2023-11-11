
**_node exporter installation_**

In order to monitor the linux server performance and process based activity via prometheus each instance should have run to the node exporter as a service. the prometheus pull the metric from node exporter via api and store it self to maintain the upon to max duration time.

create the user and folder's to handle the node exporter process itself. So we are aware of user-based processes and permissions.

```bash
sudo useradd --no-create-home -c "Monitoring user" --shell /bin/false node_exporter
```

_download the node exporter binary_

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -vxzf node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
sudo chown -R node_exporter:node_exporter  /usr/local/bin/node_exporter
```

_create the custom systemd service for node exportor_

create the file under this location `/etc/systemd/system` with the name of `node_exporter.service` include the below content

```service
# sudo vim /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus node exporter
After=network.target auditd.service

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter \
  --web.listen-address=0.0.0.0:9100 \
  --collector.tcpstat \
  --collector.bonding \
  --collector.systemd \
  --collector.systemd.unit-whitelist=(sshd|httpd|node_exporter|vsftpd|crond|firewalld|rsyslog).service \
  --collector.meminfo_numa \
  --collector.logind \
  --collector.filesystem.ignored-mount-points "^(/snap/|/run/|/dev/|/sys|/run).*" \
  --no-collector.wifi \
  --no-collector.nfs \
  --no-collector.zfs \
  --no-collector.nfsd \
  --no-collector.mdadm \
  --no-collector.arp \
  --no-collector.bcache \
  --no-collector.buddyinfo \
  --no-collector.edac \
  --no-collector.hwmon \
  --no-collector.qdisc \
  --no-collector.infiniband \
  --collector.ipvs 
  #--path.procfs=/proc 
Restart=on-failure
StandardOutput=syslog
StandardError=syslog
[Install]
WantedBy=default.target
```

_service management_

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter
sudo netstat -tulpn | grep 9100
```

**_how to integrate node exporter into prometheus_**

switch to prometheus server below the configuration must be updated 

```bash
# sudo vim /etc/prometheus/prometheus.yml
# add the new server with new node exporter
  - job_name: 'node'
    static_configs: 
    - targets: ['10.0.1.3:9100']     # server IP address
      labels: 
        instance: app-server         # server name
    - targets: ['10.0.1.4:9100']     # server IP address
      labels: 
        instance: web-server         # server name
```
_validate the prometheus configuration_

after the update to the Prometheus configuration. your config file looks like below this.

```bash
---
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
        instance: Prometheus
  - job_name: 'node'
    static_configs: 
    - targets: ['10.0.1.3:9100']     # server address 
      labels: 
        instance: app-server         # server name
    - targets: ['10.0.1.4:9100']     # server address 
      labels: 
        instance: web-server         # server name
```

_restart the prometheus service_

```bash
sudo systemctl restart prometheus
``` 

once restarted service. It will pull the data from push node exporter server.
