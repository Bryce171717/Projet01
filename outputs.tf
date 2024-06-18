output "spark_cluster_id" {
  description = "ID du cluster EMR Spark"
  value       = aws_emr_cluster.spark_cluster.id
}

output "spark_master_public_dns" {
  description = "DNS public du master EMR Spark"
  value       = aws_emr_cluster.spark_cluster.master_public_dns
}

output "mongodb_instance_id" {
  description = "ID de l'instance MongoDB"
  value       = aws_instance.mongodb.id
}

output "mongodb_public_ip" {
  description = "IP publique de l'instance MongoDB"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_public_dns" {
  description = "DNS public de l'instance MongoDB"
  value       = aws_instance.mongodb.public_dns
}
