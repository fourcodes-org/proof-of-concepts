**_ansible-implementation-on-azure_**

Azure itself provides infrastructure as a service, platform as a service, and software as a service. now a days everyone wants to provison the resource and deployment the apps as  a automation.

Depending on your or everyone's expectations, it may be possible to provide all the resources using ansible.

Ansible we are called as a configuration management tool. moreover this is user based input basically allowing to easily passing those information compared to other tools.

**Is it possible to provision infrastructure as a service via Ansible?**

yes. It is possible. By default, Ansile provides those details as a module. We can accommodate all the stuffs as a YAML and run it.

[Reference yaml](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualmachine_module.html)

```yml
- name: Create VM with defaults
  azure_rm_virtualmachine:
    resource_group: myResourceGroup
    name: testvm10
    admin_username: "{{ username }}"
    admin_password: "{{ password }}"
    image:
      offer: CentOS
      publisher: OpenLogic
      sku: '7.1'
      version: latest
```

**Is it possible to provision platform as a service via Ansible?**

Yes, it is possible. First, we will have to search the module under the "Ansible Documentation" part. If it is not there, we will have to prepare the custom library for the specific task.

these below yaml file I found under the ansible [docs](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_appserviceplan_module.html#ansible-collections-azure-azcollection-azure-rm-appserviceplan-module)

```yaml
- name: Create a windows app service plan
  azure_rm_appserviceplan:
    resource_group: myResourceGroup
    name: myAppPlan
    location: eastus
    sku: S1
```

**_how can I create the custom ansible module?_**

In that case you sould familier with python code. This the [ansible docs](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html) which is provide the custom library creation examples.

For your reference, these are the examples that I am now creating. [custom library](https://github.com/fourtimes/Documentation/tree/master/azure-webjob-ansible)

This is a custom module example for your reference.

```yaml
---
- name: all
  hosts: localhost
  vars:
    appname: testjino
    file_location: ./webapp.zip
  tasks:
  - azureAccessToken:
      tenantid: "xxxx-c3cc-xxxx-9c53-xxxxxxx"
      clientid: "xxxxx-569f-xxxx-9d4b-xxxx"
      clientsecret: "5l~pb8xhfoDO.Ea7u91b2dbCLQuN5Ae2~V"
    register: _results
  - azurewebjobsdeploy:
      appServiceName: "{{ appname }}"
      accessToken: "{{  _results.meta.accessToken  }}"
      fileLocation: "{{ file_location }}"
```
