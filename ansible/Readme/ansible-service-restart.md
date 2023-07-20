


```yml
---
# file: restart.yml
- name: RESTARTED THE NGINX SERVICE
  hosts: worker
  tasks:
  - name: RESTARTED THE NGINX SERVICE
    service:
      name: nginx  
      state: restarted
```

_exeution_

```bash

ansible-playbook restart.yml -b

```
