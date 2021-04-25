
# Defining a VPC

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    subnet1_cidr_blocks = var.subnet1_cidr_blocks
    subnet2_cidr_blocks = var.subnet2_cidr_blocks
    avail_zone1 = var.avail_zone1
    avail_zone2 = var.avail_zone2
    env_prefix = var.env_prefix
}

module "myapp-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.myapp-vpc.id
    mypublic_ip = var.mypublic_ip
    env_prefix = var.env_prefix
    avail_zone1 = var.avail_zone1
    subnet_id = module.myapp-subnet.myapp-subnet-1.id
    image_name = var.image_name
    instance_type = var.instance_type
    public_key_location = var.public_key_location
    private_key_location = var.private_key_location
}
