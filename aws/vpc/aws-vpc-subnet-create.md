# AWS VPC creation

**$$ VPC $$**

_First choose the region_

* Go to consle page and click region 
* Then select your region like `Asia Pacific (Sydney)`

![Screenshot from 2023-06-09 19-43-05](https://github.com/rio-ke/workman/assets/88568938/c84b4eb7-e3b1-4f7f-a2c5-e71eb904a1c7)

_creating Virtual private cloud_

* Go to VPC dashboard
* Then under Virtual private cloud click `Your VPC New`
* Click `Create VPC`

![create-vpc](https://github.com/rio-ke/workman/assets/88568938/8acfdc4e-62f4-4829-b9b8-d61774748a16)


- A VPC is an isolated portion of the AWS Cloud populated by AWS objects, such as Amazon EC2 instances.

_VPC settings_

Fill
* Resources to create
* Name tag
* IPv4 CIDR
* Tenancy
And then click create-vpc

![vpc-page](https://github.com/rio-ke/workman/assets/88568938/d32d6b2a-dc92-40c9-a002-4c7d1ad47112)


**$$SUB-NET$$**

A subnet is a range of IP addresses in your VPC

_IPv4_

The subnet has an IPv4 CIDR block but does not have an IPv6 CIDR block. Resources in an IPv4-only subnet must communicate over IPv4

_creating subnet_

* Open the Amazon VPC console
* In the navigation pane, choose Subnets
* Then select VPC ID in the create subnet page
* Then fill out subnet settings

![Screenshot from 2023-06-11 21-31-44](https://github.com/rio-ke/workman/assets/88568938/436475b0-c8b4-4f2e-a1df-159e28899900)

And then Click `Yellow Create subnet` button.


_**Note**_

- subnet range is within cidr block
- we can choose to differentiate num of host with subnet
