## user-and-group-finds.md

```bash
#!/usr/bin/env bash

USERS=$(cat /etc/passwd | grep -E '/bin/bash|/bin/sh' | awk -F: '{print $1}')

for USER in $USERS; do
    echo "USERNAME  - ${USER}"
    echo "GROUPNAME - $(id -gn ${USER})"
    echo ""
done

```
