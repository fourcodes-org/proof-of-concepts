_lvm-creation_

```bash
pvcreate /dev/sdb /dev/sdc /dev/sdd
vgcreate pacs-vg /dev/sdb /dev/sdc /dev/sdd
lvcreate -l 100%FREE -n pacs-vg-pacs-lv pacs-vg
sudo mkfs.ext4 /dev/pacs-vg/pacs-vg-pacs-lv
sudo mount /dev/pacs-vg/pacs-vg-pacs-lv /pacs-storage/
```
