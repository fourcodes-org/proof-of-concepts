_ansible-for-azure-bearer-token-create_

```yml
---
- name: Get Azure Access Token
  hosts: localhost
  gather_facts: no

  vars:
    TENANT_ID: xxxx
    APP_ID: xxxx
    APP_SECRET: xxxxx

  tasks:
    - name: Check if required variables are defined
      fail:
        msg: "Variables APP_ID, APP_SECRET, and TENANT_ID must be defined."
      when: APP_ID is not defined or APP_SECRET is not defined or TENANT_ID is not defined

    - name: Get Azure Access Token
      uri:
        url: "https://login.microsoftonline.com/{{ TENANT_ID }}/oauth2/token"
        method: POST
        body_format: "form-urlencoded"
        body: "grant_type=client_credentials&client_id={{ APP_ID }}&client_secret={{ APP_SECRET }}&resource=https://management.azure.com/"
        headers:
          Content-Type: "application/x-www-form-urlencoded"
        status_code: 200
        return_content: yes
      register: token_response

    - name: Display Token Response
      debug:
        var: token_response.content

```
