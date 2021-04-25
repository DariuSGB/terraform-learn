/*
## Defining a security group for blocking traffic from/to servers

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = var.vpc_id
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
    vpc_id = var.vpc_id
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
        values = [var.image_name]
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
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_default_security_group.main-sg.id]
    availability_zone = var.avail_zone1
    # Defining public IP
    associate_public_ip_address = true
    # Defining SSH keys
    key_name = aws_key_pair.ssh-key.key_name
    # Executing a BASH script
    user_data = file("./modules/webserver/entry-script.sh")

    tags = {
        Name: "${var.env_prefix}-server"
    }
}