
_monitor-the-linux-mount_

`monitor_mount.sh`

```bash
#!/bin/bash

# Replace "/path/to/mountpoint" with the actual path of the mount point you want to monitor
MOUNT_POINT="/path/to/mountpoint"

# Replace "youremail@example.com" with your email address
EMAIL="youremail@example.com"

# Check if the mount point exists
if [ ! -d "$MOUNT_POINT" ]; then
    # If the mount point does not exist, send an email notification
    echo "Mount point $MOUNT_POINT is not available on $(hostname)" | mail -s "Mount Point Not Found" "$EMAIL"
fi

```
