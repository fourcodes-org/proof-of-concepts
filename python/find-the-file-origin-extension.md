
```py

import magic
import os 


def find_the_file_origin_extension(file_location):
    if os.path.exists(file_location):
        _, extension = os.path.splitext(file_location)
        orgin_file_extension = extension[1:]
        magic_provided_exension = magic.from_file(file_location, mime=True)
        print(magic_provided_exension)
        return False if "exec" in magic_provided_exension else True
    else:
        return False
```
