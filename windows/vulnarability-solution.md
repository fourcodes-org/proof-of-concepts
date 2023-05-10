
```powershell
$registryPath = "HKLM:\Software\Microsoft\Cryptography\Wintrust\Conf"
$Name = "EnableCertPaddingCheck"
$value = "1"

IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
}
ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
}


$registryPath = "HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Conf"
$Name = "EnableCertPaddingCheck"
$value = "1"
IF(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
}
ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
}

```


```powershell
param (
  [switch]$FixIt
)

# Quick and dirty script by Rakhesh to fix unquoted path vulnerabilities in service paths
# This code is licensed under the MIT license - https://opensource.org/licenses/MIT
# https://isc.sans.edu/diary/Help+eliminate+unquoted+path+vulnerabilities/14464 for more info on the vulnerability itself - good read!

Get-Content .\ServerNames.txt | %{ 
  # Preliminary stuff for registry access
  $Type_SZ = [Microsoft.Win32.RegistryValueKind]::String
  $Hive = [Microsoft.Win32.RegistryHive]::LocalMachine
  $KeyPath = "SYSTEM\CurrentControlSet\services"

  $ComputerName = $_;
  # hat tip to http://stackoverflow.com/a/19015125 for this newer way of creating a custom object
  $ResultObj = [pscustomobject]@{
    ComputerName = $ComputerName
    Status = "Online"
    SubKey = $null
    Original = $null
    Replacement = $null
  }

  if (Test-Connection -ComputerName $ComputerName -Quiet -Count 2) { 
    # Clear the variable that will hold the registry connection
    $Reg = $null; 

    # Open remote registry and if it fails then set the status accordingly
    try { $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName) } catch { $ResultObj.Status = "Error"; $ResultObj }
    
    if ($Reg) {
      # Open the services key
      $Key = $Reg.OpenSubKey($KeyPath, $true)

      # Enumerate subkeys; and for each subkey do ...
      foreach ($SubkeyName in $Key.GetSubKeyNames()) {
        # Open the subkey read-only (else we get errors on some keys which we don't have write access to)
        $Subkey = $Key.OpenSubKey($SubkeyName, $false)
    
        # Get value of ImagePath
        $Value = $Subkey.GetValue("ImagePath")

        # Match ImagePath to see if it has an exe; if yes, extract the exe path. Note: extract only exe path, not arguments. 
        # If this extracted path doesn't start in quotes and when we split it for spaces we get more than one result, then enclose path in double quotes.
        if ($Value -match ".*\.exe" ) { 
          if (($Matches[0] -notlike '"*') -and (($Matches[0] -split '\s').Count -gt 1)) { 
            $Replacement = '"' + $Matches[0] + '"'
            $NewValue = $Value -replace ".*\.exe",$Replacement

            $ResultObj.SubKey = Split-Path -Leaf $SubKey;
            $ResultObj.Original = $Value;
            $ResultObj.Replacement = $NewValue;
        
            $ResultObj
          
            if ($FixIt) {
              # re-open the key with read-write permissions 
              $Subkey = $Key.OpenSubKey($SubkeyName, $true)
              $Subkey.SetValue("ImagePath","$Replacement");
              if ($?) { Write-Host -ForegroundColor Green "Success!" } else { Write-Host -ForegroundColor Red "Something went wrong!" }
            }
          } 
          Clear-Variable Matches
        }
      }
    }
  } else { $ResultObj.Status = "Online"; $ResultObj }
}
```
