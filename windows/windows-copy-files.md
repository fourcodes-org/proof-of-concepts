

_windows copy file one to another_

_pre-requisties_

```ps1
Enable-PSRemoting
WinRM quickconfig
winrm get winrm/config/client
# winrm s winrm/config/client '@{TrustedHosts="RemoteComputer"}'
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
# set-item WSMan:\localhost\Client\TrustedHosts "*"
winrs -r:172.xx.xx.xx -u:'useradmin' -p:'password' powershell "hostname"
```

_script_

```ps1
$Username = "mike"
$Password = ConvertTo-SecureString "Password@123" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

$session = New-PSSession -ComputerName 10.3.0.7 -Credential $Credential

Copy-Item -Path 'C:\backup\*.*' -Destination 'C:\backup' -ToSession $session
$session | Remove-PSSession
```
