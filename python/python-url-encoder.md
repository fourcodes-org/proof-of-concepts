

```py

import urllib.parse

string_to_encode = "1alP6FJmB4pCH0GEwJK2dNcRmCsgkXLkb1y5rrOWibAnqTucTOwFWvFMJpyVQUfysAKuZNfIR7rJWarEet+nxAWCmuGzbNaTnEQupH3XZWy9qLK13QufATiuKCXSBw0eorea9Vo4Pdb8fCxl7nLvgaXNciFmEzTycQMqOZT0idmc="
encoded_string = urllib.parse.quote(string_to_encode)

print(encoded_string)
```
