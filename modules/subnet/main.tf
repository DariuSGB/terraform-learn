## Defining Subnets

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet1_cidr_blocks
    availability_zone = var.avail_zone1
    tags = {
        Name: "${var.env_prefix}-subnet1"
    }
}

resource "aws_subnet" "myapp-subnet-2" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet2_cidr_blocks
    availability_zone = var.avail_zone2
    tags = {
        Name: "${var.env_prefix}-subnet2"
    }
}

## Defining an Internal GW for sending traffic to internet

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

/*
## Defining a new routing table

resource "aws_route_table" "myapp-rtb" {
    vpc_id = var.vpc_id
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
    default_route_table_id = var.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}
