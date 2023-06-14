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
Note:
  - create the public-rt using the above manner
```
`route to the IGW in public-rt`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/fb757a74-f006-4dcd-bf4f-ab14906abd07)

`subnet association for public subnet`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/776b1a5f-8a23-438d-ad1a-935f759adc87)

`subnet association for private subnet`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e9b025d9-64b0-4af0-bade-9d791c38c916)

**EC2 Instance with Security Group:**
---

`create the public instance name - one`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/fb6de43d-1409-4a55-8110-93cc90caf613)

`create the private instance name - two`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/5a2f9b91-5170-4f53-aeb9-2648930efca5)

**Check the output connectivity:**
---

```sh
  - login to the public instance
  - check the network connectivity to that instance using this command `ping google.com`
  - Then login to the private instace from the public instance.
```
`output`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/4eb16292-1643-4f89-8517-d6520972839f)

**NAT Gateway:**
---
Inside the private instance, how can we give a internet connection:

```sh
  - create the NAT gateway to public subnet.
  - Attach the NAT gateway to an private RT route.
  - We have to login the public instance through SSH.
  - Inside the public instance we have to login the private instance through SSH.
  - After logging in, we check whether the internet process is working or not. While working, we need to put in some commands. In case it is not working, we need to check the creation       of the Nat Gateway.
    `sudo apt install vim`
```
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/8642ee67-e506-4014-8b89-21f583916d40)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/da075ee7-4522-4956-9a5a-6d1d35219a13)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/ffc6774e-cef7-4d6a-8e73-a7affd627436)

Note: 
  - Please refer this url for NAT gateway process - https://cloudiofy.com/how-to-connect-ec2-instance-in-a-private-subnet/



Using ICMP, we need to give the network connection for private instance

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/940f11b7-1af9-490d-b4df-07ca12b0d0d6)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/af798d96-75e5-458a-ace9-b2b9f0f915ea)


