resource "aws_instance" "mongodb" {
  ami             = var.mongodb_ami
  instance_type   = "t2.micro"
  key_name        = var.mongodb_key_name
  security_groups = [var.mongodb_security_group]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y mongodb
    sudo systemctl start mongodb
    sudo systemctl enable mongodb
    mongo admin --eval "db.createUser({user: '${var.mongodb_username}', pwd: '${var.mongodb_password}', roles:[{role:'root',db:'admin'}]});"
  EOF

  tags = {
    Name = "MongoDB Server"
  }
}
