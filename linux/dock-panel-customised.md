## How to customize dock panel on Ubuntu 20.04 Focal Fossa Linux

* utilize dconf-Editor via the command line

```cmd
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
```
```cmd
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
```
```cmd
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
```
```cmd
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64

```
```cmd
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
```
#
_revert_ 
```cmd
gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size
```
