

```pwsh

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose

Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose

bcdedit /set hypervisorlaunchtype Auto
```
