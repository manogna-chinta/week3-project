resource "aws_db_subnet_group" "database_subnet_group" {
  name       = var.database-subnets
  subnet_ids = [var.private_data_subnet_az1_id, var.private_data_subnet_az2_id] # Replace with your private subnet IDs
}

resource "aws_db_instance" "database" {
  identifier              = "manogna-website-db-instance"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  username                = var.database_username
  password                = var.database_password
  database_name           = var.database_name
  multi_az                = true
  storage_type            = "gp2"
  storage_encrypted       = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0

  vpc_security_group_ids = [var.database_security_group_id]  # Replace with your desired security group ID

  database_subnet_group_name = aws_database_subnet_group.database-subnet.name

  tags = {
    Name = "manogna-wesbite-db"
  }
}
