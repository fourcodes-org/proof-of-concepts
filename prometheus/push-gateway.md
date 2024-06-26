**_pushgateway installation_**

create the user and folder's to handle the pushgateway process itself. So we are aware of user-based processes and permissions.

```bash
sudo useradd --no-create-home -c "Monitoring user" --shell /bin/false pushgateway
```


_download the pushgateway binary_

```bash
wget https://github.com/prometheus/pushgateway/releases/download/v1.5.1/pushgateway-1.5.1.linux-amd64.tar.gz
tar -xvzf pushgateway-1.5.1.linux-amd64.tar.gz
mv pushgateway-1.5.1.linux-amd64/pushgateway /usr/local/bin/
sudo chown -R pushgateway:pushgateway /usr/local/bin/pushgateway
```

_custom systemd service_

to supervise the pushgateway service We can easily create the systemd service in Linux, and we can be aware of how we can start and stop those binaries.


```service
# /etc/systemd/system/pushgateway.service
[Unit]
Description=Pushgateway
Wants=network-online.target
After=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway \
    --web.listen-address=":9091" \
    --web.telemetry-path="/metrics" \
    --persistence.file="/tmp/metric.store" \
    --persistence.interval=5m \
    --log.level="info" 

[Install]
WantedBy=multi-user.target
```
_service management_

```bash
sudo systemctl daemon-reload
sudo systemctl enable pushgateway
sudo systemctl start pushgateway
sudo netstat -tulpn
```
_how to integrate node exporter into prometheus_

switch to prometheus server below the configuration must be updated 

```
# vim /etc/prometheus/prometheus.yml
# add the new server with new push gateway exporter
  - job_name: 'gateway'
    static_configs: 
    - targets: ['10.0.1.2:9091']     # server address 
      labels: 
        instance: gateway-server     # server name
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
  - job_name: 'gateway'
    static_configs: 
    - targets: ['10.0.1.2:9091']     # server address 
      labels: 
        instance: gateway-server     # server name
```

_restart the prometheus service_

```bash
sudo systemctl restart prometheus
``` 
once restarted service. It will pull the data from push gateway server.


_how to publish the custom metric to pushgateway_

```bash
echo "some_metric 3.14" | curl --data-binary @- http://10.0.1.2:9091/metrics/job/cron_job/instance/10.0.1.2
# Find the metrics
curl -L http://localhost:9091/metrics/
# If you want delete the request
curl -X DELETE http://10.0.1.2:9091/metrics/job/cron_job/instance/10.0.1.2
```
    
_custom query based on tasks and publish to prometheus_

```bash
#!/usr/bin/env bash

# bash cron_batchtrigger.sh
# Environment Labels Name
#    jobname: cron_job
#    instance: 10.0.1.2
command=$(curl -s -o /dev/null -I -w "%{http_code}" https://google.com)
if [ $command == 200 ]; then
    echo "login_trigger 0" | curl --data-binary @- http://10.0.1.2:9091/metrics/job/cron_job/instance/10.0.1.2
else
    echo "login_trigger 1" | curl --data-binary @- http://10.0.1.2:9091/metrics/job/cron_job/instance/10.0.1.2
fi
```
