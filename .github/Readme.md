## docs

```bash
scp -r -i demo.pem ubuntu@4.194.8.82:~/demo .
```

[meeting](https://teams.microsoft.com/l/meetup-join/19:meeting_MzhmYTBkMWUtNDlkYS00ZDcwLTg2YWItMjQ5MDQzZmZhNmJj@thread.v2/0?context=%7B%22Tid%22:%221d04408b-5753-4b63-9dfd-9d4c8a26e0c9%22,%22Oid%22:%22fb698c1d-6481-446b-87ef-2a3ee3654c4b%22%7D)

_git Release flow_

```bash
git add index.json
git commit -m "added"
git tag -a v1.0 HEAD -m "v1.0 tag created"
git push origin v1.0
git checkout -b develop
git push --set-upstream origin develop
git checkout -b feature/v2.0
git push --set-upstream origin feature/v2.0
# Create a pull request from feature/v2.0 into develop
git checkout develop
git pull
git checkout -b Release/v2.0
git push --set-upstream origin Release/v2.0
git pull
# Create a pull request from Release/v2.0 into main
git checkout main
git pull 
git tag -a v2.0 HEAD -m "v2.0 tag created"
git push origin v2.0
```



* Linux 
    * All concepts

* ansible
    * host
    * ansible.cfg
    * adhoc
    * playbooks
    * roles
    * conditions
    * iteration
    * variable and variable preference

* terraform
    * provider
    * resource
    * variable
    * module

* cloud 
    * aws
    * azure
    * googlecloud
       * infra as a service
       * platform as a service

* git
    * commit
    * clone
    * pull request
    * revert
    * rebase

* prometheus Grafana
    * installation and configuration


* elasticsearch

* python
    * conditions
    * iteration
    * variable and variable preference
    * function
    * class
* nodejs
    * conditions
    * iteration
    * variable and variable preference
    * function
    * class
    
* golang
    * conditions
    * iteration
    * variable and variable preference
    * function
    * class

* docker
* kubernetes
* basic networks
    * networks 
    * subnet calculations
    * firewalls

* shell script
    * variable
    * debug
    * function
    * while
    * for
    * conditional statements

* ticketing tools Jira GitHub projects azure devOps kanban Board


* automation
    * GitHub action
    * azure devOps
    * Bitbucket pipelines
    * GitLab pipelines
    * Jenkins
    * Code Build and deploy
    * GitLab
