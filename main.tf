
## We are using AWS as Provider

provider "aws" {
    region = "eu-west-3"
}

## Variable definition

variable mypublic_ip {}
variable vpc_cidr_blocks {}
variable subnet1_cidr_blocks {}
variable subnet2_cidr_blocks {}
variable avail_zone1 {}
variable avail_zone2 {}
variable env_prefix {}
variable instance_type {}
variable public_key_location {}
variable private_key_location {}

# Defining a VPC

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

## Defining Subnets

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet1_cidr_blocks
    availability_zone = var.avail_zone1
    tags = {
        Name: "${var.env_prefix}-subnet1"
    }
}

resource "aws_subnet" "myapp-subnet-2" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet2_cidr_blocks
    availability_zone = var.avail_zone2
    tags = {
        Name: "${var.env_prefix}-subnet2"
    }
}

/*
## Defining a new routing table

resource "aws_route_table" "myapp-rtb" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

## Associating subnets with the routing table

resource "aws_route_table_association" "a-rtb-subnet1" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-rtb.id
}

resource "aws_route_table_association" "a-rtb-subnet2" {
    subnet_id = aws_subnet.myapp-subnet-2.id
    route_table_id = aws_route_table.myapp-rtb.id
}
*/

## Defining the default routing table

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

## Defining an Internal GW for sending traffic to internet

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

/*
## Defining a security group for blocking traffic from/to servers

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id
    # Incomming traffic
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.mypublic_ip
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = var.mypublic_ip
    }
    # Ongoing traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-sg"
    }
}
*/


## Defining the default security group for blocking traffic from/to servers

resource "aws_default_security_group" "main-sg" {
    vpc_id = aws_vpc.myapp-vpc.id
    # Incomming traffic
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.mypublic_ip
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = var.mypublic_ip
    }
    # Ongoing traffic
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-main-sg"
    }
}

## Checking what the most recent Amazon Machine Image is

data "aws_ami" "lastest-ami" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# Defining a SSH key

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

## Defining an EC2 instance

resource "aws_instance" "myapp-server" {
    # Defining Server instance
    ami = data.aws_ami.lastest-ami.id
    instance_type = var.instance_type
    # Defining Subnet, SG and AZ
    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.main-sg.id]
    availability_zone = var.avail_zone1
    # Defining public IP
    associate_public_ip_address = true
    # Defining SSH keys
    key_name = aws_key_pair.ssh-key.key_name
    # Executing a BASH script
    user_data = file("entry-script.sh")

    tags = {
        Name: "${var.env_prefix}-server"
    }
}

## Printing Amazon Machine Instance ID and Public IP

output "aws_ami_id" {
    value = data.aws_ami.lastest-ami.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}