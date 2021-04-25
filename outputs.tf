## Printing Amazon Machine Instance ID and Public IP

output "aws_ami_id" {
    value = module.myapp-server.aws_ami_id
    
}

output "ec2_public_ip" {
    value = module.myapp-server.ec2_instance.public_ip
}
