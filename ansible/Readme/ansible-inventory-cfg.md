# creating ansible.cfg file in local directory

* create folder for ansible.cfg in  ansible server in ubuntu server 

```cmd 
mkdir ansible
```

**Generating a sample `ansible.cfg` file**

_ad-hoc command_

* You can create a fully commented-out example ansible.cfg file by doing the following:

```cmd
ansible-config init --disabled > ansible.cfg
```

* You can also have a more complete conf file that includes existing plugins:

```cmd
ansible-config init --disabled -t all > ansible.cfg
```

**_check the version and `cfg` file location_**

```cmd
ansible --version
```

_Now go to ansible.cfg file and edit inventory file path_

```bash
sudo vim ansible.cfg
```
Edit

```bash
# (pathlist) Comma separated list of Ansible inventory sources
inventory=hosts
```

Now check hosts server 

**_Hosts_**

```bash
[myvirtualmachines]
192.168.0.104 ansible_connection=ssh ansible_ssh_user=server ansible_ssh_pass=.  #username #password
```
check hosts connection in terminal with ad-hoc command
```bash
ansible all --list-hosts
```
_ping host server_

```cmd
ansible -m ping all
```
**if error accourd**

![UNREACHABLE!](https://user-images.githubusercontent.com/88568938/209984742-0cae0005-f93b-450d-90e2-db1e0a45b16f.png)

![error-find](https://user-images.githubusercontent.com/88568938/209984748-8a6ca70e-ee82-4bba-acfb-7128a75e2d01.png)

* need to add `192.168.0.104 ansible_connection=ssh ansible_ssh_user=server ansible_ssh_pass=.  #username #password` in hosts

