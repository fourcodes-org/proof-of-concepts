# Install Gradle on Ubuntu 20.04

* Gradle needs installation of Java

```cmd
java -version
```

_Downloading Gradle_

* download the Gradle binary-only zip file in url

```url
https://gradle.org/releases/
```

_Unpack the distribution_

```cmd
mkdir /opt/gradle
unzip -d /opt/gradle gradle-8.1.1-bin.zip
ls /opt/gradle/gradle-8.1.1
```
`LICENSE  NOTICE  bin  README  init.d  lib  media`

_Configure your system environment_

* Configure your PATH environment variable to include the bin directory of the unzipped distribution,

```bsh
export PATH=$PATH:/opt/gradle/gradle-8.1.1/bin
```

_Verifying installation_

```cmd
gradle -v
```





