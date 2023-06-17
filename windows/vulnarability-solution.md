_The remote Windows host is potentially missing a mitigation for a remote code execution vulnerability_

```powershell
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Cryptography\Wintrust\Config" /f /v EnableCertPaddingCheck /t Reg_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" /f /v EnableCertPaddingCheck /t Reg_DWORD /d 1

```

_Windows Speculative Execution Configuration Check_

```powershell
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /f /v FeatureSettingsOverride /t REG_DWORD /d 72
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /f /v FeatureSettingsOverrideMask /t REG_DWORD /d 3
```

_TLS Disable_

```powershell
# Disable TLS 1.0

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" /f /v DisabledByDefault /t Reg_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" /f /v Enabled /t Reg_DWORD /d 0

# Disable TLS 1.1

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /f /v DisabledByDefault /t Reg_DWORD /d 1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /f /v Enabled /t Reg_DWORD /d 0

# Enable TLS 2.0

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /f /v DisabledByDefault /t Reg_DWORD /d 0
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /f /v Enabled /t Reg_DWORD /d 4294967295

# Disable DES/3DES

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56" /f /v Enabled /t Reg_DWORD /d 0
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" /f /v Enabled /t Reg_DWORD /d 0

# Disable RC4 (Not Required)

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" /f /v Enabled /t Reg_DWORD /d 0
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" /f /v Enabled /t Reg_DWORD /d 0
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" /f /v Enabled /t Reg_DWORD /d 0
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128" /f /v Enabled /t Reg_DWORD /d 0```
```

_Microsoft Windows Unquoted Service Path Enumeration_

```powershell
$BaseKeys = "HKLM:\System\CurrentControlSet\Services"

#Blacklist for keys to ignore
$BlackList = $Null
#Create an ArrayList to store results in
$Values = New-Object System.Collections.ArrayList
#Discovers all registry keys under the base keys
$DiscKeys = Get-ChildItem -Recurse -Directory $BaseKeys -Exclude $BlackList -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Name | %{($_.ToString().Split('\') | Select-Object -Skip 1) -join '\'}
#Open the local registry
$Registry = [Microsoft.Win32.RegistryKey]::OpenBaseKey('LocalMachine', 'Default')
ForEach ($RegKey in $DiscKeys)
{
    #Open each key with write permissions
    Try { $ParentKey = $Registry.OpenSubKey($RegKey, $True) }
    Catch { Write-Debug "Unable to open $RegKey" }
    #Test if registry key has values
    If ($ParentKey.ValueCount -gt 0)
    {
        $MatchedValues = $ParentKey.GetValueNames() | ?{ $_ -eq "ImagePath" -or $_ -eq "UninstallString" }
        ForEach ($Match in $MatchedValues)
        {
            #RegEx that matches values containing .exe with a space in the exe path and no double quote encapsulation
            $ValueRegEx = '(^(?!\u0022).*\s.*\.[Ee][Xx][Ee](?<!\u0022))(.*$)'
            $Value = $ParentKey.GetValue($Match)
            #Test if value matches RegEx
            If ($Value -match $ValueRegEx)
            {
                $RegType = $ParentKey.GetValueKind($Match)
                If ($RegType -eq "ExpandString")
                {
                    #RegEx to generate an unexpanded string to use for correcting
                    $ValueRegEx = '(^(?!\u0022).*\.[Ee][Xx][Ee](?<!\u0022))(.*$)'
                    #Get the value without expanding the environmental names
                    $Value = $ParentKey.GetValue($Match, $Null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                    $Value -match $ValueRegEx
                }
                #Uses the matches from the RegEx to build a new entry encapsulating the exe path with double quotes
                $Correction = "$([char]34)$($Matches[1])$([char]34)$($Matches[2])"
                #Attempt to correct the entry
                Try { $ParentKey.SetValue("$Match", "$Correction", [Microsoft.Win32.RegistryValueKind]::$RegType) }
                Catch { Write-Debug "Unable to write to $ParentKey" }
                #Add a hashtable containing details of corrected key to ArrayList
                $Values.Add((New-Object PSObject -Property @{
                "Name" = $Match
                "Type" = $RegType
                "Value" = $Value
                "Correction" = $Correction
                "ParentKey" = "HKEY_LOCAL_MACHINE\$RegKey"
                })) | Out-Null
            }
        }
    }
    $ParentKey.Close()
}
$Registry.Close()
$Values | Select-Object ParentKey,Value,Correction,Name,Type
```

_new user add securoty configuration_

```ps1
# Ensure 'Always install with elevated privileges
reg add  "HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Windows\Installer" /f /v "AlwaysInstallElevated" /t Reg_DWORD /d 0  

#  "19.7.28.1 Ensure 'Prevent users from sharing files within their profile.' is set to 'Enabled'" : [FAILED]
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'  /f /v 'NoInplaceSharing'   /t Reg_DWORD /d 1

# "19.7.8.5 Ensure 'Turn off Spotlight collection on Desktop' is set to 'Enabled'"
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Policies\Microsoft\Windows\CloudContent' /f /v 'DisableSpotlightCollectionOnDesktop'   /t Reg_DWORD /d 1

# 19.7.7.2 (L1) Ensure 'Do not suggest third-party content in Windows spotlight' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Policies\Microsoft\Windows\CloudContent'  /f /v 'DisableThirdPartySuggestions'   /t Reg_DWORD /d 1

# "19.7.8.1 Ensure 'Configure Windows spotlight on lock screen' is set to Disabled'" : [FAILED]
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Policies\Microsoft\Windows\CloudContent'  /f /v 'ConfigureWindowsSpotlight'   /t Reg_DWORD /d 2


# 19.7.4.2 (L1) Ensure 'Notify antivirus programs when opening attachments' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments'  /f /v 'ScanWithAntiVirus'   /t Reg_DWORD /d 3

# "19.7.4.1 Ensure 'Do not preserve zone information in file attachments' is set to 'Disabled'" : [FAILED]
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments'  /f /v 'SaveZoneInformation'   /t Reg_DWORD /d 2

# 19.5.1.1 (L1) Ensure 'Turn off toast notifications on the lock screen' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'  /f /v 'NoToastApplicationNotificationOnLockScreen'   /t Reg_DWORD /d 1

# 19.7.45.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer'  /f /v 'PreventCodecDownload'   /t Reg_DWORD /d 1

# 19.7.7.3 (L2) Ensure 'Do not use diagnostic data for tailored experiences' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\Software\Policies\Microsoft\Windows\CloudContent'  /f /v 'DisableTailoredExperiencesWithDiagnosticData'   /t Reg_DWORD /d 1

# 19.6.5.1.1 (L2) Ensure 'Turn off Help Experience Improvement Program' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'  /f /v 'NoImplicitFeedback'   /t Reg_DWORD /d 1

# 19.7.45.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer'  /f /v 'PreventCodecDownload'   /t Reg_DWORD /d 1


#  19.1.3.4 (L1) Ensure 'Screen saver timeout' is set to 'Enabled: 900 seconds or fewer, but not 0'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop'  /f /v 'ScreenSaveTimeOut'   /t Reg_DWORD /d 900


#  19.1.3.3 (L1) Ensure 'Password protect the screen saver' is set to 'Enabled'
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop'  /f /v 'ScreenSaverIsSecure'   /t Reg_DWORD /d 1

# "19.1.3.1 Ensure 'Enable screen saver' is set to 'Enabled'" : [FAILED]
reg add 'HKU\S-1-5-21-3441312238-2935593948-1070341977-1005\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop'  /f /v 'ScreenSaveActive'   /t Reg_DWORD /d 1

```

_common user configuration_

```ps1
# 18.9.47.6.1 Ensure 'Enable file hash computation feature' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\MpEngine" /f /v EnableFileHashComputation /t REG_DWORD /d 1
# 18.9.47.9.4 Ensure 'Turn on script scanning' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v DisableScriptScanning /t REG_DWORD /d 1
# 18.9.64.1 Ensure 'Turn off Push To Install service' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\PushToInstall" /f /v DisablePushToInstall /t REG_DWORD /d 1
# 18.9.17.7 Ensure 'Limit Dump Collection' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection" /f /v LimitDumpCollection /t REG_DWORD /d 1
# 18.9.17.6 Ensure 'Limit Diagnostic Log Collection' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection" /f /v LimitDiagnosticLogCollection /t REG_DWORD /d 1
# 18.9.17.3 Ensure 'Disable OneSettings Downloads' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection" /f /v EnableOneSettingsAuditing /t REG_DWORD /d 1
# 18.9.17.3 Ensure 'Disable OneSettings Downloads' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection" /f /v DisableOneSettingsDownloads /t REG_DWORD /d 1
# 18.9.14.1 Ensure 'Turn off cloud consumer account state content' is set to 'Enabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent" /f /v DisableConsumerAccountStateContent /t REG_DWORD /d 1
# spooler enable process
reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Spooler' /f /v 'Start'   /t Reg_DWORD /d 4

# 18.5.4.1 Ensure 'Configure DNS over HTTPS (DoH) name resolution' is set to 'Enabled: Allow DoH' or higher
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\DNSClient" /f /v DoHPolicy /t REG_DWORD /d 2
# "18.6.2 Ensure 'Point and Print Restrictions: When installing drivers for a new connection' is set to 'Enabled: Show warning and elevation prompt'" : [FAILED]
reg add 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint' /f /v 'NoWarningNoElevationOnInstall'   /t Reg_DWORD /d 0

# "18.6.3 Ensure 'Point and Print Restrictions: When updating drivers for an existing connection' is set to 'Enabled: Show warning and elevation prompt'" : [FAILED]
reg add 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint' /f /v 'UpdatePromptSettings'   /t Reg_DWORD /d 0

#  18.3.6 (L1) Ensure 'NetBT NodeType configuration' is set to 'Enabled: P-node (recommended)'
reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetBT\Parameters'  /f /v 'NodeType'   /t Reg_DWORD /d 2

# Disable IPv6
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\tcpip6\parameters" /v DisabledComponents /t REG_DWORD /d 0xFF /f
# 18.6.1 Ensure 'Allow Print Spooler to accept client connections' is set to 'Disabled'
reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers" /f /v RegisterSpoolerRemoteRpcEndPoint /t REG_DWORD /d 2
# 18.6.2 Ensure 'Point and Print Restrictions: When installing drivers for a new connection' is set to 'Enabled: Show warning and elevation prompt'

```
