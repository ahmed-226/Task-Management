# ===========================================
# Outputs - Information after deployment
# ===========================================

output "app_public_ip" {
  description = "Public IP address of the application server"
  value       = aws_eip.app.public_ip
}

output "app_public_dns" {
  description = "Public DNS of the application server"
  value       = aws_instance.app.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = var.key_name != "" ? "ssh -i ${var.key_name}.pem ec2-user@${aws_eip.app.public_ip}" : "No SSH key configured"
}

output "app_url" {
  description = "Application URL"
  value       = "http://${aws_eip.app.public_ip}"
}

output "api_url" {
  description = "API URL"
  value       = "http://${aws_eip.app.public_ip}:4000"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.app.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app.id
}

# ===========================================
# Next Steps (displayed after apply)
# ===========================================

output "next_steps" {
  description = "Instructions after deployment"
  value       = <<-EOT
    
    ✅ Infrastructure deployed successfully!
    
    Next steps:
    1. SSH into the server:
       ${var.key_name != "" ? "ssh -i ${var.key_name}.pem ec2-user@${aws_eip.app.public_ip}" : "Create an SSH key pair first"}
    
    2. Clone your repository:
       git clone https://github.com/ahmed-226/Task-Management.git
       cd Task-Management
    
    3. Start the application:
       docker-compose up -d
    
    4. Access the application:
       Frontend: http://${aws_eip.app.public_ip}:3000
       API:      http://${aws_eip.app.public_ip}:4000
    
  EOT
}
