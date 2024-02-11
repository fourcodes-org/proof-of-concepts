
_Install_

```bash
sudo apt-get update
sudo apt-get install apt-transport-https -y
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update
sudo apt-get install dart -y
```

data types

```dart
void main() {
  String name = "four";

  print(name);

  int number = 4;

  print(number);

  double float = 9.18;

  print(float);

  var identity = "human";

  print(identity);

  const String project = "demo";

  print(project);

  final String work = "development";

  print(work);

  bool isValid = false;

  print(isValid);
}
```

if conditions

```dart
void main() {
  String name = "four";
  print("total length of :  ${name.length}");
  if (name == "four") {
    print("correct value");
  } else {
    print("wrong value");
  }
}
```

elif conditions

```dart
void main() {
  String name = "four";
  print("total length of :  ${name.length}");
  if (name == "four") {
    print("correct value");
  } else if (name == 4) {
    print("mimatch value");
  } else {
    print("wrong value");
  }
}
```

__switch case_

```dart
void main() {
  String name = "four";

  switch (name) {
    case "fours":
      {
        print(name);
      }
    case "four":
      {
        print(name);
      }
    case "one":
      {
        print(name);
      }
    default:
      {
        print("null values passed");
      }
  }
}
```

for loop

```dart
void main() {
  for (var i = 1; i <= 10; i++) {
    print("Development value is : ${i}");
  }
}

```

while loop


```dart
void main() {
  int count = 0;

  while (count < 5) {
    print('Count: $count');
    count++;
  }
}

```


```dart
void main() {
  List numbers = [1, 2, 3, 4];

  for (int number in numbers) {
    print(number);
  }

  List names = ["jino", "mike", "john"];

  for (String name in names) {
    print(name);
  }
}

```
