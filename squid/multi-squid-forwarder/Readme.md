_squid configuration_

|squid name | subnet range|
|---|---|
| iz-it-squid  | 10.209.139.208/29 |
| ez-it-squid  | 172.25.5.144/29 |
| ez-gut-squid | 172.24.131.144/29 |

_traffic flow_

     [Client]
        |
        | iz-it-squid   (192.168.10.2)
        |
        | ez-it-squid   (192.168.10.3)
        |
        | ez-gut-squid  (192.168.10.4)
        |
    [Internet]
