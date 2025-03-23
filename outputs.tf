output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}
output "k3s_node_private_ip" {
  value = aws_instance.k3s_node.private_ip
}