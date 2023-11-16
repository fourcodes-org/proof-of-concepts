**Err:10 https://updates.signal.org/desktop/apt xenial InRelease**                                                                         
      **The following signatures couldn't be verified because the public key is not available: NO_PUBKEY D980A17457F6FB06**

**_`Solution:`_**
```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D980A17457F6FB06
```
```sh
sudo apt update
sudo apt upgrade
```
---
**W: GPG error: https://updates.signal.org/desktop/apt xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY D980A17457F6FB06**

**_`Solution:`_**

```sh
# 
Download the Signal public key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
```
```sh
sudo apt update
sudo apt upgrade
```
---

**E: The repository 'https://updates.signal.org/desktop/apt xenial InRelease' is not signed.**

**_`Solution:`_**
```sh
# Remove the existing Signal repository entry
sudo rm -f /etc/apt/sources.list.d/signal-xenial.list

# Add the Signal repository
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list

#     Retrieve and add the Signal public key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
```
```sh
sudo apt update
sudo apt upgrade
```

