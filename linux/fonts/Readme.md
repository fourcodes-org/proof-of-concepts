to install the Calibri font on Ubuntu, you can use the following script

```bash
sudo apt-get update
sudo apt-get install fontforge
sudo apt-get install cabextract
wget https://raw.githubusercontent.com/januo-org/proof-of-concepts/main/linux/fonts/font-installation.sh -q -O - | sudo bash
```

_manual steps_

```bash
#!/usr/bin/env bash

# Update the package list and install the font installer
sudo apt update
sudo apt install fonts-crosextra-carlito

# Create a temporary directory to download the font files
mkdir -p ~/temp_calibri_install
cd ~/temp_calibri_install

# Download the Calibri font files
wget https://example.com/calibri-font.zip

# Unzip the font files
unzip calibri-font.zip

# Move the font files to the system's font directory
sudo mv *.ttf /usr/share/fonts/truetype/

# Update the font cache
sudo fc-cache -f -v

# Clean up temporary files
rm -rf ~/temp_calibri_install

echo "Calibri font has been successfully installed."
To install the Calibri font on Ubuntu, you can use the following script:
```
