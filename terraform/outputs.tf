output "ec2_ip" {
  description = "IP of EC2 to SSH"
  value       = module.gfginfra.web_ssh_ip
}

output "ssh_priv_key" {
  description = "Private Key of EC2"
  value       = module.gfginfra.web_ssh_priv_key
}

output "rds_endpoint" {
  description = "Endpoint of publicly accesible RDS Postgres"
  value       = module.gfginfra.rds_endpoint
}
