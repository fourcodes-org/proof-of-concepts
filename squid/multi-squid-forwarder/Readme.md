_squid configuration_

|squid name | subnet range|
|---|---|
| iz-it-squid  | 192.168.10.2 |
| ez-it-squid  | 192.168.10.3 |
| ez-gut-squid | 192.168.10.4 |

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
