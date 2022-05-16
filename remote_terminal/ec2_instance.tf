# Create the EC2 instance that Terraform will run commands on for CloudHSM
resource "aws_instance" "this" {
  instance_type                        = "t3.micro"
  ami                                  = "ami-0c6120f461d6b39e9" # Amazon Linux 2
  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile   = aws_iam_instance_profile.this.id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]

  key_name = aws_key_pair.this.key_name

  tags = { Name = var.name }
}
