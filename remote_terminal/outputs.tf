output "id" {
  value = aws_instance.this.id
}
output "ip" {
  value = aws_instance.this.public_ip
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
output "role_name" {
  value = aws_iam_role.this.name
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.this.private_key_openssh
}
