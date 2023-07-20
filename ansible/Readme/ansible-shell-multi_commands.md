# Ansible-playbook for shell module task with ymal 


_Run shell ansible-modules to run command in ansibe-playbook_

```yml
---
- name: shell modules tasks
  hosts: k
  tasks:
    - name: use this task to verify the linux server's version and OS-details
      shell:
            "lsb_release -a"
      register: result
    - debug:
        msg: "{{ result.stdout_lines }}"
```

_Runing shell ansible-modules to run command in playbook with loop_

```yml
---
- name: shell modules tasks
  hosts: k
  tasks:
    - name: Get hostname
      shell: "{{ item }}"
      # when: # and or condition
      # no_true: false # hide messages
      # ignore_errors: # Even if we got the error, to continue the play.....
      register: result
      loop:
        - hostname
        - uname -o
        - groups
    - name: print the result
      debug:
        msg: "{{ result | json_query('results[].stdout') }}"
        # use json_query when you use loop method.....{ "msg": []}

```

_Runing shell-modules to call variable in playbook with loop and conditions_

```yml
---
- name: shell modules tasks
  hosts: j
  become_user: root
  become_method: sudo
  vars:
    run_cmd:
      - hostname
      - lsb_release -a
  tasks:
    - name: check host
      ping:
    - name: Get hostname
      shell:
        "{{ item }}"
        # "lsb_release -a"
      register: result
      ignore_errors: true
      loop: "{{ run_cmd }}"
      when:
    - debug:
        msg: "{{ result|json_query('results[*].stdout') }}"

```

