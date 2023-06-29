## Download desired fonts
`https://fonts.google.com/?selection.family=Open+Sans`  

## Install Google Fonts on Ubuntu
`cd /usr/share/fonts`  
`sudo mkdir googlefonts`  
`cd googlefonts`  
`sudo unzip -d . ~/Downloads/Open_Sans.zip`  
`sudo chmod -R --reference=/usr/share/fonts/opentype /usr/share/fonts/googlefonts`  

## Register fonts
`sudo fc-cache -fv`  

## Check if font installed
`fc-match OpenSans` 
