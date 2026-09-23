output "bastion_public_ip" {
  description = "Public address used only as the SSH gateway"
  value       = aws_instance.bastion.public_ip
}

output "private_server_ip" {
  description = "RFC1918 address reachable through the bastion"
  value       = aws_instance.private_server.private_ip
}

output "ssh_config" {
  description = "Example ~/.ssh/config entries"
  value = templatefile("${path.module}/templates/ssh_config.tftpl", {
    bastion_ip = aws_instance.bastion.public_ip
    private_ip = aws_instance.private_server.private_ip
  })
}

