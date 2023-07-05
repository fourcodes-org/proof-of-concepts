

```pwsh

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose

Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose

bcdedit /set hypervisorlaunchtype Auto

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
