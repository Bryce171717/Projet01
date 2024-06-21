# Fournisseur AWS
provider "aws" {
  region = "eu-west-3"  # Région de Paris
}

# Variables pour les informations sensibles (à remplacer par vos valeurs)
variable "mongodb_username" {
  type        = string
  description = "Nom d'utilisateur administrateur pour MongoDB"
  sensitive   = true
  default     = "admin01"  # Remplacez par votre nom d'utilisateur
}

variable "mongodb_password" {
  type        = string
  description = "Mot de passe administrateur pour MongoDB"
  sensitive   = true
  default     = "1234"     # Remplacez par votre mot de passe fort
}

# Cluster EMR (Apache Spark)
resource "aws_emr_cluster" "Spark_Cluster" {
  name          = "SparkCluster01"
  release_label = "emr-7.1.0"  # Choisissez une version plus récente si possible
  applications  = ["Hadoop", "Hive", "JupyterEnterpriseGateway", "Livy", "Spark"]
  service_role = "arn:aws:iam::031131961798:role/service-role/AmazonEMR-ServiceRole-20240505T140225"
  log_uri       = "s3://aws-logs-031131961798-eu-west-3/elasticmapreduce"

  ec2_attributes {
    instance_profile            = "arn:aws:iam::031131961798:instance-profile/EmrEc2S3Full"
    subnet_id                  = "subnet-00508a1e4ac0faf28"
    emr_managed_master_security_group = "sg-01ceb80944ffa01d6"
    emr_managed_slave_security_group  = "sg-0852ccf141b26f385"
    key_name                   = "SSH_Mongodb"
  }

  master_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 1
    name           = "Primaire"
  }

  core_instance_group {
    instance_type = "m5.xlarge"
    instance_count = 2
    name           = "Unité principale et unité de tâches"
  }

  # Configuration du connecteur MongoDB (avec IP privée)
  configurations_json = jsonencode([
    {
      Classification = "spark-defaults",
      Properties     = {
        "spark.jars.packages"   = "org.mongodb.spark:mongo-spark-connector_2.12:3.0.1",
        "spark.mongodb.input.uri"  = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${aws_instance.mongodb.private_ip}:27017/database01",
        "spark.mongodb.output.uri" = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${aws_instance.mongodb.private_ip}:27017/database01"
      }
    }
  ])

  scale_down_behavior = "TERMINATE_AT_TASK_COMPLETION"
  auto_termination_policy {
    idle_timeout = 3600
  }
}

# Instance EC2 MongoDB (Améliorée)
resource "aws_instance" "mongodb" {
  ami           = "ami-087da76081e7685da"  # AMI Ubuntu Server 22.04 LTS
  instance_type = "m5.large"
  key_name      = "SSH_Mongodb"

  # Stockage EBS pour MongoDB
  root_block_device {
    volume_size = 50
  }

  vpc_security_group_ids = ["sg-01ceb80944ffa01d6", "sg-0852ccf141b26f385"]

  # Script d'installation et de configuration de MongoDB (Amélioré)
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y mongodb-org

    # Créer l'utilisateur admin
    sudo systemctl start mongod
    sleep 10 
    mongo --eval "db.createUser({user:'${var.mongodb_username}', pwd:'${var.mongodb_password}', roles:[{role:'root', db:'admin'}]})"

    sudo systemctl enable mongod
  EOF

  tags = {
    Name = "MongoDB Server"
  }
}

# Bucket S3 pour stocker les données
resource "aws_s3_bucket" "data_bucket" {
  bucket = "S3_datas" 

  # Configuration du cycle de vie des objets, chiffrement, etc. (à ajouter selon vos besoins)
}

# Sorties
output "cluster_id" {
  value = aws_emr_cluster.Spark_Cluster.id
}

output "master_public_dns" {
  value = aws_emr_cluster.Spark_Cluster.master_public_dns
}

output "mongodb_instance_status" {
  value = aws_instance.mongodb.instance_state
}

output "mongodb_private_ip" {
  value = aws_instance.mongodb.private_ip
}

output "data_bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}
