provider "aws" {
  region = "eu-west-3"
}

resource "aws_emr_cluster" "Spark_Cluster" {
  name          = "SparkCluster01"
  release_label = "emr-7.1.0"
  applications  = ["Hadoop", "Hive", "JupyterEnterpriseGateway", "Livy", "Spark"]
  service_role = "arn:aws:iam::031131961798:role/service-role/AmazonEMR-ServiceRole-20240505T140225"
  log_uri       = "s3://aws-logs-031131961798-eu-west-3/elasticmapreduce"

  ec2_attributes {
    instance_profile                 = "arn:aws:iam::031131961798:instance-profile/EmrEc2S3Full"
    subnet_id                        = "subnet-00508a1e4ac0faf28"
    emr_managed_master_security_group = "sg-01ceb80944ffa01d6"
    emr_managed_slave_security_group  = "sg-0852ccf141b26f385"
    key_name			      = "SSH_Mongodb"
  }


  master_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 1
    name           = "Primaire"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 2
    name           = "Unité principale et unité de tâches"
  }
#Configuration du connecteur mongodb
configurations_json = jsonencode([
  {
    Classification = "spark-defaults",
    Properties = {
      "spark.jars.packages" = "org.mongodb.spark:mongo-spark-connector_2.12:3.0.1",
      "spark.mongodb.input.uri" = "mongodb://[admin01]:[1234]@[mongodb]:27017/[database01]",
      "spark.mongodb.output.uri" = "mongodb://[admin01]:[1234]@[mongodb]:27017/[database01]"
    }
  }
])

#  task_instance_group {
#    instance_type  = "m5.xlarge"
#    instance_count = 1
#    name           = "Tâche - 1"
#  }

  scale_down_behavior = "TERMINATE_AT_TASK_COMPLETION"
  auto_termination_policy {
    idle_timeout = 3600
  }
}

output "cluster_id" {
  value = aws_emr_cluster.Spark_Cluster.id
}

output "master_public_dns" {
  value = aws_emr_cluster.Spark_Cluster.master_public_dns
}
# Création d'une instance ec2 contenant mongodb
resource "aws_instance" "mongodb" {
  ami           = "ami-087da76081e7685da"
  instance_type = "t2.micro"
  key_name      = "SSH_Mongodb"


# Même sécurity group que le cluster spark
  vpc_security_group_ids = ["sg-01ceb80944ffa01d6", "sg-0852ccf141b26f385"]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y mongodb
              sudo systemctl start mongodb
              sudo systemctl enable mongodb
              EOF

  tags = {
    Name = "MongoDB Server"
  }
}


output "mongodb_instance_status" {
  value = aws_instance.mongodb.instance_state
}

output "mongodb_public_dns" {
  value = aws_instance.mongodb.public_dns
}

output "mongodb_public_ip" {
  value = aws_instance.mongodb.public_ip
}