resource "aws_emr_cluster" "spark_cluster" {
  name          = "SparkCluster01"
  release_label = "emr-7.1.0"
  applications  = ["Hadoop", "Hive", "JupyterEnterpriseGateway", "Livy", "Spark"]
  log_uri       = var.emr_log_uri

  ec2_attributes {
    instance_profile           = var.emr_instance_profile
    subnet_id                  = var.subnet_id
    emr_managed_master_security_group = var.emr_security_group_master
    emr_managed_slave_security_group  = var.emr_security_group_slave
  }

  master_instance_group {
    instance_type = var.instance_type
    instance_count = 1
    name = "Master"
  }

  core_instance_group {
    instance_type = var.instance_type
    instance_count = 2
    name = "Core"
  }

  scale_down_behavior = "TERMINATE_AT_TASK_COMPLETION"

  auto_termination_policy {
    idle_timeout = 3600
  }

  service_role = var.emr_service_role
}
