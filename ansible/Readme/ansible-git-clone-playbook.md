## ansible-git-clone-playbook

```yml
# file: clone.yml
---
- name: ansible playbooks
  hosts: all
  vars:
    GIT_USERNAME: "fourtimes"
    GIT_TOKEN: "ghp_ZJZ1uTvI9SBytt42nMxxxxxxxxxxx"
    DESTINATIN: "/tmp/github"
    BRANCH_NAME: "dev"
    REPO_NAME: "dummy"
    REPO_ACCOUNT: "FourTimes"
  tasks:
    - name: Get updated files from git repository
      git: 
        repo: https://{{ GIT_USERNAME }}:{{ GIT_TOKEN }}@github.com/{{ REPO_ACCOUNT }}/{{ REPO_NAME }}.git
        dest: "{{ DESTINATIN }}"
        # single_branch: yes
        version: "{{ BRANCH_NAME }}"
```

_execution_

```bash
ansible-playbook clone.yml
```
