```bash
docker-compose --env-file env/env.dynamic up -d
```

nano /etc/sysctl.conf

```bash
net.nf_conntrack_max = 131072
net.core.somaxconn = 131072
kernel.msgmnb = 131072
kernel.msgmax = 131072
fs.file-max = 131072
```
