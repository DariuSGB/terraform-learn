## Printing Amazon Machine Instance ID and Public IP

output "aws_ami_id" {
    value = data.aws_ami.lastest-ami.id
}

output "ec2_instance" {
    value = aws_instance.myapp-server
}