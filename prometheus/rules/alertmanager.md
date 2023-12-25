_alert_

```yml
---
global:
  resolve_timeout: 30s
  slack_api_url: 'https://hooks.slack.com/services/xxx/xxx/xxx'

# templates:
#   - /etc/alertmanager/notifications.tmpl

route:
  # fallback receiver
  receiver: linux-team-admin
  group_wait: 2m
  group_interval: 10s
  repeat_interval: 1m
  routes:
    - match_re:
        app_type: (linux|windows|container)
      receiver: linux-team-admin
      routes:
        - match:
            app_type: linux
          receiver: linux-team-admin
          routes:
            - match:
                severity: critical
              receiver: linux-team-manager
            - match:
                severity: warning
              receiver: linux-team-lead
            - match:
                severity: info
              receiver: linux-team-admin

        - match:
            app_type: container
          receiver: linux-team-admin
          routes:
            - match:
                severity: critical
              receiver: linux-team-manager
            - match:
                severity: warning
              receiver: linux-team-lead
            - match:
                severity: info
              receiver: linux-team-admin

inhibit_rules:
  - source_match:
      severity: "critical"
    target_match:
      severity: "warning"
    equal: ["app_type", "category"]

receivers:
  - name: "linux-team-admin"
    slack_configs:
      - send_resolved: true
        channel: "#sbmch-product-info"
        icon_url: "https://avatars3.githubusercontent.com/u/3380462"
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
        channel: "#sbmch-product-warnings"
        icon_url: "https://avatars3.githubusercontent.com/u/3380462"
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
    slack_configs:
      - send_resolved: true
        channel: "#sbmch-product-critical"
        icon_url: "https://avatars3.githubusercontent.com/u/3380462"
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
```
