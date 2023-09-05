_executabl-file-finder_

```py
import os

def is_executable(file_path):
    executable_signatures = [b'MZ', b'PE\0\0']
    with open(file_path, 'rb') as file:
        content = file.read(2)
        if any(signature in content for signature in executable_signatures):
            return True

    return False

# Input the file path, including the renamed file if applicable
file_path = "rufus-4.2.pdf"

# Check if the file is executable
if is_executable(file_path):
    print("This file is not allowed due to its executable nature.")
else:
    print("This file is safe to use.")
    

```
