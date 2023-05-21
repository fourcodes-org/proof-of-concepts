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
