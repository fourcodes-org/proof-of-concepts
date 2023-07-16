
_Bad approach_

```py
body = {
    "name": "gino",
    "class": "python",
    "duration": 1,
    "age": 45
}

if len(body) == 3:
    if all(key in body for key in ["name", "class", "duration"]):
        print("valid")
    else:
        print("invalid")
else:
    print("invalid")
```

_Good approach_

```py
body = {
    "name": "gino",
    "class": "python",
    "duration": 1,
    "age": 45
}

required_keys = {"name", "class", "duration"}

if len(body) == 3 and required_keys.issubset(body.keys()):
    print("valid")
else:
    print("invalid")
```
