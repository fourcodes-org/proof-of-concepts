
**playbooks**

```yml
---
# users-find-bash.yml
- name: find the users with /bin/bash
  hosts: localhost
  tasks:
    - name: find the users with /bin/bash
      shell: |
        cat /etc/passwd | grep /bin/bash | awk -F: '{print $1}'
      register: _users
    - name: dispaly the users with /bin/bash
      debug:
        msg: "{{ item }}"
      with_items: "{{ _users.stdout_lines}}"

```

**execution commands**

```bash

ansible-playbook users-find-bash.yml -b

```

