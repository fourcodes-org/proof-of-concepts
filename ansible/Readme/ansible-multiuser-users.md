# Adding multible users with loop with variable in ansible playbook

```yml
---
- name: finding shell command with conditional and loop and variables
  hosts: node
  become: yes

  vars:
    ans_er:
        - kendanic
        - kentnick
        - rosario
  tasks:
    - name: creating users in ubuntu server
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
        shell: /bin/bash
        groups: root
        # append: yes
      register: created
      loop: "{{ ans_er }}"
    - debug:
        msg: "{{ created | json_query('results[*].shell') }}"
  ```     
   
