_redhat rpm package query_

```yml
---
# version-finder.yml
- name: Package versions findings
  hosts: all
  tasks:
  - name: GET INPUT VERSIONS
    debug:
      msg: "Expected 1 Args"
    when: packages is not defined
  - set_fact: 
      output: "{{ packages | split(',') | list }}"
    when: packages is defined
  - name: GET PACKAGE VERSIONS
    shell: "rpm -qa {{ item }}"
    with_items: 
      - "{{ output }}"
    register: _version_details
    when: packages is defined
  - name: PRINT THE PACKAGE VERSIONS
    debug:
      msg: "{{ _version_details.results | json_query('[].stdout[]') }}"
    when: packages is defined
```

_Execution command_

```bash
# single package query
ansible-playbook version-finder.yml -e packages=httpd

# Multi package query
ansible-playbook version-finder.yml -e packages=httpd,vsftpd
```

_outputs_

[![demo](https://asciinema.org/a/nS8TEgAxJ5HJPPzFhGkUxBvdv.svg)](https://asciinema.org/a/nS8TEgAxJ5HJPPzFhGkUxBvdv?autoplay=1)

