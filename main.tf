variable "myresources" {
    description = "This is the CIDR block for VPC and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

variable "avail_zone" {}

resource "aws_vpc" "lab-vpc" {
    cidr_block = var.myresources[0].cidr_block
    tags = {
        Name: var.myresources[0].name
    }
}

resource "aws_subnet" "mgmt-subnet" {
    vpc_id = aws_vpc.lab-vpc.id
    cidr_block = var.myresources[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.myresources[1].name
    }
}

output "lab-vpc-id" {
    value = aws_vpc.lab-vpc.id
}

output "lab-subnet-id" {
    value = aws_subnet.mgmt-subnet.id
}
