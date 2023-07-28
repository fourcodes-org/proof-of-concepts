
_python_

```py
import re

class PatternChecks:
    def __init__(self, file_path):
        self.pattern = ['A_B/|A_BC/|A_C/|A/|B_C/|B_CD/|B_D/|B/|C/|C_B/|C_BA/|D_B/|C/']
        self.file_path = file_path

    def find_combinations(self):
        matches = re.findall(self.pattern[0], self.file_path)
        return [matches[0] if matches != [] else False]

    def check_key_matching_patterns(self):
        compiled_patterns = [re.compile(pattern.replace("/", r"\/").replace("_", r"\w+")) for pattern in self.pattern]
        if self.find_combinations()[0] != False:
            for key in self.find_combinations():
                for pattern in compiled_patterns:
                    if pattern.fullmatch(key):
                        return key.replace("/", "")
        return False
```

_usage_

```py
pt = PatternChecks("path/A_B/demo.txt")
print(pt.check_key_matching_patterns())
```
