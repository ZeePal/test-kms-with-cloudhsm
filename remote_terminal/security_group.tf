resource "aws_security_group" "this" {
  name   = "remote-terminal-${var.name}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "inbound_internet_to_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  protocol         = "TCP"
  from_port        = 22
  to_port          = 22
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  type              = "egress"
  security_group_id = aws_security_group.this.id

  protocol         = "-1"
  from_port        = 0
  to_port          = 65535
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
