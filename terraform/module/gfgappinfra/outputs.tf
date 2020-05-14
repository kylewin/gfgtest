output "web_ssh_ip" {
  description = "IP of web EC2"
  value       = aws_instance.web.public_ip
}

output "web_ssh_priv_key" {
  description = "Private Key of EC2"
  value       = tls_private_key.web_priv_key.private_key_pem
}


output "rds_endpoint" {
  description = "RDS Postgres Endpoint"
  value       = aws_db_instance.gfg_postgres.endpoint
}

