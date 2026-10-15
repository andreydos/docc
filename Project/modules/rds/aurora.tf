resource "aws_rds_cluster" "aurora" {
  count                           = var.use_aurora ? 1 : 0
  cluster_identifier              = var.name
  engine                          = var.engine_cluster
  engine_version                  = var.engine_version_cluster
  database_name                   = var.db_name
  master_username                 = var.username
  master_password                 = var.password
  db_subnet_group_name            = aws_db_subnet_group.default.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  backup_retention_period         = var.backup_retention_period
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  storage_encrypted               = var.storage_encrypted
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.name}-final"
  port                            = local.db_port

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !contains(["db.t3.micro", "db.t4g.micro"], var.instance_class)
      error_message = "Aurora не підтримує db.t3.micro і db.t4g.micro. Вкажіть щонайменше db.t3.medium."
    }
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count                = var.use_aurora ? var.aurora_instance_count : 0
  identifier           = "${var.name}-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.aurora[0].id
  instance_class       = var.instance_class
  engine               = var.engine_cluster
  engine_version       = var.engine_version_cluster
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count       = var.use_aurora ? 1 : 0
  name        = "${var.name}-aurora-params"
  family      = var.parameter_group_family_aurora
  description = "Aurora cluster parameter group for ${var.name}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = var.parameter_apply_method
    }
  }

  tags = var.tags
}
