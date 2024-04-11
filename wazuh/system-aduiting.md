## Monitoring system calls

* Wazuh uses the Linux Audit system to monitor system calls on Linux endpoints. The Wazuh agent installs and configures audit rules on monitored endpoints to collect system call events and sends them to the Wazuh server for analysis. These audit rules capture events relevant to security monitoring. Wazuh provides out-of-the-box detection rules that use the system call events to detect multiple activities, including file access, command execution, privilege escalation, malware, and more. Security teams can customize these rules to meet specific security requirements or compliance standards, thereby obtaining real-time insights into potential security incidents.

**Install the audit package**

```cmd
apt install -y auditd
```

**Add the configuration below to the Wazuh agent configuration**

```cmd
vim /var/ossec/etc/ossec.conf
```
```xml
<localfile>
  <log_format>audit</log_format>
  <location>/var/log/audit/audit.log</location>
</localfile>
```

**Restart the Wazuh agent**

```cmd
systemctl restart wazuh-agent
```

**check log**

```cmd
tail -f /var/log/audit/audit.log
```

**Monitoring file and directory access**

_Ubuntu endpoint_

_Run the commands_

```cmd
echo "-w /home -p w -k audit-wazuh-w" >> /etc/audit/audit.rules
echo "-w /home -p a -k audit-wazuh-a" >> /etc/audit/audit.rules
echo "-w /home -p r -k audit-wazuh-r" >> /etc/audit/audit.rules
echo "-w /home -p x -k audit-wazuh-x" >> /etc/audit/audit.rules
```
```cmd
auditctl -R /etc/audit/audit.rules
auditctl -l
```
* Audit configuration alerts are displayed in the Security Events and System Auditing tab of the Wazuh dashboard
* now create file and agent server

```cmd
touch /home/malware.py
```
* You can visualize the alert data in the Wazuh dashboard


