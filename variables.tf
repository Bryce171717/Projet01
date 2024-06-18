variable "aws_region" {
  description = "Région AWS à utiliser"
  type        = string
  default     = "eu-west-3"
}

variable "mongodb_username" {
  description = "Nom d'utilisateur administrateur pour MongoDB"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "Mot de passe administrateur pour MongoDB"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Type d'instance EC2 pour le cluster Spark et MongoDB"
  type        = string
  default     = "m5.xlarge"
}

variable "subnet_id" {
  description = "ID du sous-réseau où les instances seront déployées"
  type        = string
}

variable "emr_log_uri" {
  description = "URI du bucket S3 pour les logs EMR"
  type        = string
}

variable "emr_instance_profile" {
  description = "Profil d'instance IAM pour les instances EMR"
  type        = string
}

variable "emr_service_role" {
  description = "Rôle de service IAM pour EMR"
  type        = string
}

variable "emr_security_group_master" {
  description = "Groupe de sécurité pour le master EMR"
  type        = string
}

variable "emr_security_group_slave" {
  description = "Groupe de sécurité pour les slaves EMR"
  type        = string
}

variable "mongodb_ami" {
  description = "AMI pour l'instance MongoDB"
  type        = string
  default     = "ami-087da76081e7685da"  # AMI Debian
}

variable "mongodb_key_name" {
  description = "Nom de la clé SSH pour accéder à MongoDB"
  type        = string
}

variable "mongodb_security_group" {
  description = "Groupe de sécurité pour MongoDB"
  type        = string
}
