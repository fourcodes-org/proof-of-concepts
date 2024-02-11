
_Install_

```bash
sudo apt-get update
sudo apt-get install apt-transport-https -y
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt-get update
sudo apt-get install dart -y
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
