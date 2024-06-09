provider "aws" {
  region = "eu-west-3"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "app" {
  ami           = "ami-052984d1804039ba8"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  tags = {
    Name = "chatbot-app"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker run -d -p 5000:5000 chatbot-api"
    ]
  }
}

output "instance_ip" {
  value = aws_instance.app.public_ip
}
