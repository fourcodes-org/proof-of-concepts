## VPC Peering:

 A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses.

## VPC Peering Configuration:

**VPC**
---
`1. We have to create the 2 VPC.`
![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/d38972c3-9765-4071-beca-f23c60f5a102)

**Subnet**
---
`2. Then We need to create the subnet on each VPC.`
![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/2bf9413a-cf0d-4e37-b236-f505dd4706e0)

**Internet Gateway:**
---
`3. Then We have to Create the IGW for each VPC.`
![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/d550aee8-660a-461e-b630-19671b1e0c95)

**Route Table**
---
`4. We have to Create the RT for each VPC.`
![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/f06cb355-3bda-4fd1-963f-d70989396215)

`vpc1 subnet association:`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/76cf53fd-1624-423d-a340-7ed87d7b6b08)

`default subnet association:`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/df255892-2f15-460d-89ef-591eb9a6ab2c)

`5. We need to configure the Specified IGW for each RT.`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/132617e8-9c5b-46a4-8372-33d43588d210)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/6192affc-085e-4e95-909f-a0a7ba871e93)

**EC2 Instance & Security Group:**
---
`6. Then We have to create a separate instance on each VPC and create a separate SG for each subnet of VPC with the help of allow all traffic`
![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/18808e25-7229-4ada-b52d-f68e36770920)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/7ec9b9dc-01ee-4e82-95d6-34a375f1444a)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/dd2c221e-ade7-4ada-b714-bdb06d768e4d)

**Validate the connectivity**
---
`8. After creating the instance, we need to check the network connectivity of each instance.`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/d6071c80-cbe2-4952-b420-14f3e0538f77)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/ee3ef85c-b796-4352-a2e7-c95ad0a1caa5)

**VPC Peering**
---
`9. Then we will configure the VPC Peering for 2 VPCs.`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/943417c3-e9fe-447c-8c88-4a5c1338a60e)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/247662bf-ccb3-4f0d-886b-eadd27e89f89)

**Route Table**
`10. Route the connection each RT`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/d1ba8c87-3c3b-4c77-b26a-09e75789b173)

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/7d8fbdb7-b280-41e9-91f4-1a6ca6e89676)

**Checking the peering connectivity**
`11. After the peering connection, we have to check the connectivity of this process the below method.`

- login to the instance 1
- then the this command `ping (ins 2 private IP)`

                [or]
- login to the instance 2
- then the this command `ping (ins 1 private IP)`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/b0350281-6a6f-4b29-97d5-761655127fc5)

