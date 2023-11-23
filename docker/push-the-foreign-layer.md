add the part under the daemon.json file

`C:\ProgramData\docker\config`

```json
{
    "allow-nondistributable-artifacts": [
        "xxxx4212806.dkr.ecr.ap-southeast-1.amazonaws.com"
    ]
}

```

_session manager_
```pwsh
$certdatas= @"
{
    "allow-nondistributable-artifacts": [
        "xxxxx.dkr.ecr.ap-southeast-1.amazonaws.com"
    ]
}
"@
echo $certdatas | set-content daemon.json
```
