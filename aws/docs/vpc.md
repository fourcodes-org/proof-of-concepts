## Infrastructure of VPC Concepts

**VPC**
---
`1. Firstly, we have to create the VPC.` 

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/acfed3ea-666f-4e88-b0c3-d4a6568bb068)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/795eca04-bb38-4f3e-bdc6-276e0ca56b8b)

**Subnet**
---

`2. Then, we have to create the subnet under the VPC.`

```sh
- under the VPC, we have to create n number of subnets
```
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/6d25cb09-7960-445e-9fc9-5e4fe706e364)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a77c1410-8657-4c6e-b31f-7aa814bc2dc5)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e1dce85d-c990-4029-ba42-f772bc8c7828)

```sh
Note:
  - After creating subnet 1, you need to use the above method of subnet 1 to create subnet 2.
  - subnet 2 cidr rage is 192.168.2.0/24.
  - subnet 1 as a public.
  - subnet 2 as a private.
```

**Internet Gateway**
---
`3. Route the internet into the VPC`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/0df13d84-0c8c-4197-80f0-3a530e88840e)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/627b3997-4844-4752-846b-16213b8e09de)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a94ffad8-7bac-4808-9a35-3f866f83a548)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/75b7ad8b-149e-4c48-bd67-dec1afe12f1b)

**Route Table:**
---
`create the private route table`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e0a3e6e2-e554-4f05-8b16-6f94e04b25fb)

```sh
- create the public-rt using the above manner
```
`route to the IGW in public-rt`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/fb757a74-f006-4dcd-bf4f-ab14906abd07)

`subnet association for public subnet`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/776b1a5f-8a23-438d-ad1a-935f759adc87)

`subnet association for private subnet`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e9b025d9-64b0-4af0-bade-9d791c38c916)





