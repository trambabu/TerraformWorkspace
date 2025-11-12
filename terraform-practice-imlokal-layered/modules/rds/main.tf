resource "aws_db_subnet_group" "this" {
  name       = "practice-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "practice-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier        = "practice-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = var.enable_multi_az
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "practice-mysql"
  }
}
