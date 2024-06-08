provider "aws" {
  region = "eu-west-3"  # Région Europe (Paris)
}

resource "aws_instance" "app" {
  ami           = "ami-052984d1804039ba8"  # A adapter en fonction des besoins
  instance_type = "t2.micro"
  tags = {
    Name = "chatbot-app"
  }
  provisioner "remote-exec" {
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
