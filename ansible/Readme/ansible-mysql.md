**_Ansible-mysql configuration_**

```yml
---
- hosts: pod
  become: yes
  tasks:
    - name: Installing Mysql-server
      apt:
        name: "{{item}}"
        state: present
        update_cache: yes
      register: output
      loop:
        - mysql-client
        - mysql-server
      # become: yes
    - name: print output
      ansible.builtin.debug:
        msg: "{{ output | json_query('results[*].item') }}"
    - name: Install pip
      apt:
        name: "{{ item }}"
        state: present
        update_cache: yes
      register: output_1
      with_items:
        - mysql-server
        - python3-pip
        - libmysqlclient-dev
        - python3-dev
        - python3-mysqldb
    - name: print output
      ansible.builtin.debug:
        msg: "{{ output_1 | json_query('results[].item') }}"

    - name: start and enable mysql service
      service:
        name: mysql
        state: started
        enabled: yes

    - name: creating mysql user
      mysql_user:
        name: "db_user"
        password: "db_pass"
        priv: "*.*:ALL"
        host: "%"
        state: present

    - name: creating demo_db
      mysql_db:
        name: "demo_db"
        state: present
    - name: Enable remote login to mysql
      lineinfile:
        path: /etc/mysql/mysql.conf.d/mysqld.cnf
        regexp: "^bind-address"
        line: "bind-address = 0.0.0.0"
        backup: yes
    #       notify: Restart Keepalived

    # handlers:
    - name: Restart mysql
      service:
        name: mysql
        state: restarted

```


_**Execution**_

```cmd
ansible-playbook playbook/ansible-mysql.yml
```
