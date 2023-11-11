
create the user and folder's to handle the node exporter process itself. So we are aware of user-based processes and permissions.

```bash
sudo useradd --no-create-home -c "alert user" --shell /bin/false alertuser
```

_download the binary_

```bash
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz
tar -xvzf alertmanager-0.26.0.linux-amd64.tar.gz
sudo mv alertmanager-0.26.0.linux-amd64/alertmanager /usr/local/bin/
sudo mv alertmanager-0.26.0.linux-amd64/amtool /usr/local/bin/
```

_permission access for alertuser_

```bash
sudo chown -R alertuser:alertuser /usr/local/bin/alertmanager
sudo chown -R alertuser:alertuser /usr/local/bin/amtool

```

_alertmanager configuration_

```bash
sudo mkdir /etc/alertmanager/ 
sudo mkdir -p /var/alertmanager/data/
sudo chown -R alertuser:alertuser /var/alertmanager/data/
```

_create the notification templates_

create the file under this location `/etc/alertmanager` with the name of `notifications.tmpl` include the below content

```j2
# sudo vim /etc/alertmanager/notifications.tmpl

{{ define "__single_message_title" }}{{ range .Alerts.Firing }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ range .Alerts.Resolved }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ end }}

{{ define "custom_title" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}{{ template "__single_message_title" . }}{{ end }}{{ end }}

{{ define "custom_slack_message" }}
{{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}
{{ range .Alerts.Firing }}{{ .Annotations.description }}{{ end }}{{ range .Alerts.Resolved }}{{ .Annotations.description }}{{ end }}
{{ else }}
{{ if gt (len .Alerts.Firing) 0 }}
*Alerts Firing:*
{{ range .Alerts.Firing }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
{{ end }}{{ end }}
{{ if gt (len .Alerts.Resolved) 0 }}
*Alerts Resolved:*
{{ range .Alerts.Resolved }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
{{ end }}{{ end }}
{{ end }}
{{ end }}
```

_create the alartmanager configuration_

create the file under this location `/etc/alertmanager` with the name of `alertmanager.yml` include the below content

```bash
# sudo vim /etc/alertmanager/alertmanager.yml
global:
  resolve_timeout: 30s

templates:
  - /etc/alertmanager/notifications.tmpl

route:
  # fallback receiver
  receiver: admin
  group_wait: 2m
  group_interval: 10s
  repeat_interval: 1m
  routes:
    - match_re:
        app_type: (linux|windows)
      # fallback receiver
      receiver: ss-admin
      # group_by: [severity]
      routes:
        # Linux team
        - match:
            app_type: linux
          # fallback receiver
          receiver: linux-team-admin
          routes:
            - match:
                severity: critical
              receiver: linux-team-manager
            - match:
                severity: warning
              receiver: linux-team-lead

        # Windows team
        - match:
            app_type: windows
          # group_by: [severity]
          # fallback receiver
          receiver: windows-team-admin
          routes:
            - match:
                severity: critical
              receiver: windows-team-manager
            - match:
                severity: warning
              receiver: windows-team-lead

      # test Technologies.
    - match_re:
        app_type: (python|go)
      # fallback receiver
      receiver: pec-admin
      routes:
        # Python team
        - match:
            app_type: python
          # fallback receiver
          receiver: python-team-admin
          routes:
            - match:
                severity: critical
              receiver: python-team-manager
            - match:
                severity: warning
              receiver: python-team-lead

        # Go team
        - match:
            app_type: go
          # fallback receiver
          receiver: go-team-admin
          routes:
            - match:
                severity: critical
              receiver: go-team-manager
            - match:
                severity: warning
              receiver: go-team-lead

inhibit_rules:
  - source_match:
      severity: "critical"
    target_match:
      severity: "warning"
    equal: ["app_type", "category"]

receivers:
  - name: "admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "ss-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "pec-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "linux-team-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "linux-team-lead"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "linux-team-manager"
    email_configs:
      - to: "receiver_mail_id@gmail.com"
        from: "mail_id@gmail.com"
        smarthost: smtp.gmail.com:587
        auth_username: "mail_id@gmail.com"
        auth_identity: "mail_id@gmail.com"
        auth_password: "password"

  - name: "windows-team-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "windows-team-lead"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "windows-team-manager"
    email_configs:
      - to: "receiver_mail_id@gmail.com"
        from: "mail_id@gmail.com"
        smarthost: smtp.gmail.com:587
        auth_username: "mail_id@gmail.com"
        auth_identity: "mail_id@gmail.com"
        auth_password: "password"

  - name: "python-team-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "python-team-lead"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "python-team-manager"
    email_configs:
      - to: "receiver_mail_id@gmail.com"
        from: "mail_id@gmail.com"
        smarthost: smtp.gmail.com:587
        auth_username: "mail_id@gmail.com"
        auth_identity: "mail_id@gmail.com"
        auth_password: "password"

  - name: "go-team-admin"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "go-team-lead"
    slack_configs:
      - send_resolved: true
        channel: "#general"
        slack_api_url: "https://hooks.slack.com/services"
        title: '{{ .Status | toUpper }}{{ if eq .Status "firing" }} - {{ .Alerts.Firing | len }}{{ end }} | PROMETHEUS ALERTS'
        text: >-
          {{ range .Alerts }}
            *Alert:* {{ .Annotations.summary }}
            *State:* `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
            *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}

  - name: "go-team-manager"
    email_configs:
      - to: "receiver_mail_id@gmail.com"
        from: "mail_id@gmail.com"
        smarthost: smtp.gmail.com:587
        auth_username: "mail_id@gmail.com"
        auth_identity: "mail_id@gmail.com"
        auth_password: "password"

```

_custom systemd servixce_

create the file under this location `/etc/systemd/system` with the name of `alertmanager.service` include the below content

```service
# /etc/systemd/system/alertmanager.service
[Unit]
Description=Prometheus AlertManager
After=network.target auditd.service

[Service]
User=alertuser
ExecStart=/usr/local/bin/alertmanager --config.file "/etc/alertmanager/alertmanager.yml" --storage.path "/var/alertmanager/data/"
Restart=on-failure
StandardOutput=syslog
StandardError=syslog

[Install]
WantedBy=default.target
```

_service management_

```bash
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager
sudo systemctl status alertmanager
sudo netstat -tulpn
```


_basic rules_

```yml
# sudo vim /etc/prometheus/linux.yml

groups:
  - name: linux-rules
    rules:

    - alert: NodeExporterDown
      expr: up{job="node_exporter"} == 0
      for: 2m
      labels:
        severity: critical
        app_type: linux
        category: server
      annotations:
        summary: "Node Exporter is down"
        description: "Node Exporter is down for more than 2 minutes"

    - record: job:node_memory_Mem_bytes:available
      expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

    - alert: NodeMemoryUsageAbove60%
      expr: 60 < (100 - job:node_memory_Mem_bytes:available) < 75
      for: 2m
      labels:
        severity: warning
        app_type: linux
        category: memory
      annotations:
        summary: "Node memory usage is going high"
        description: "Node memory for instance {{ $labels.instance }} has reached {{ $value }}%"
        app_link: 'http://localhost:8000/'
        
    - alert: NodeMemoryUsageAbove75%
      expr: (100 - job:node_memory_Mem_bytes:available) >= 75
      for: 2m
      labels:
        severity: critical
        app_type: linux
        category: memory
      annotations:
        summary: "Node memory usage is very HIGH"
        description: "Node memory for instance {{ $labels.instance }} has reached {{ $value }}%"

    - alert: NodeCPUUsageHigh
      expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 80
      for: 2m
      labels:
        severity: critical
        app_type: linux
        category: cpu
      annotations:
        summary: "Node CPU usage is HIGH"
        description: "CPU load for instance {{ $labels.instance }} has reached {{ $value }}%"

    - alert: NodeCPU_0_High
      expr: 100 - (avg by(instance, cpu) (irate(node_cpu_seconds_total{mode="idle", cpu="0"}[1m])) * 100) > 80
      for: 2m
      labels:
        severity: critical
        app_type: linux
        category: cpu
      annotations:
        summary: "Node CPU_0 usage is HIGH"
        description: "CPU_0 load for instance {{ $labels.instance }} has reached {{ $value }}%"

    - alert: NodeCPU_1_High
      expr: 100 - (avg by(instance, cpu) (irate(node_cpu_seconds_total{mode="idle", cpu="1"}[1m])) * 100) > 80
      for: 2m
      labels:
        severity: critical
        app_type: linux
        category: cpu
      annotations:
        summary: "Node CPU_1 usage is HIGH"
        description: "CPU_1 load for instance {{ $labels.instance }} has reached {{ $value }}%"

    - alert: NodeFreeDiskSpaceLess30%
      expr: (sum by (instance) (node_filesystem_free_bytes) / sum by (instance) (node_filesystem_size_bytes)) * 100 < 30
      for: 2m
      labels:
        severity: warning
        app_type: linux
        category: disk
      annotations:
        summary: "Node free disk space is running out"
        description: "Node disk is going to full (< 30% left)\n  Current free disk space is {{ $value }}"
```
