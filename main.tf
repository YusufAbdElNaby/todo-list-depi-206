provider "aws" {
  region  = "us-east-1"  # West Virginia region
  profile = "devops_profile"
}
# Define the key pair resource
resource "aws_key_pair" "my_key_pair" {
  key_name = "my-key-pair"  # Name for the key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key file
}

resource "aws_security_group" "my_sg" {
  name_prefix = "my-security-group-"
  description = "Allow SSH and other ports"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["<PUBLIC_IP_PLACEHOLDER>/32"]  # Replace with your IP address or range
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 25
    to_port   = 25
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 465
    to_port   = 465
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 3000
    to_port   = 10000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30000
    to_port   = 32767
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami = "ami-0e86e20dae9224db8"  # Ubuntu AMI ID for your region
  instance_type = "t3.medium"
  key_name = "my-key-pair"  # Replace with your key pair name
  tags = {
    Name = "jenkins"
  }

  security_groups = [aws_security_group.my_sg.name]
  spot_price = "0.045"  # Replace with your desired max spot price
}
resource "aws_instance" "sonarqube" {
  ami = "ami-0e86e20dae9224db8"  # Ubuntu AMI ID for your region
  instance_type = "t3.medium"
  key_name = "my-key-pair"  # Replace with your key pair name
  tags = {
    Name = "sonarqube"
  }

  security_groups = [aws_security_group.my_sg.name]
  spot_price = "0.045"  # Replace with your desired max spot price
}
resource "aws_instance" "nexus" {
  ami = "ami-0e86e20dae9224db8"  # Ubuntu AMI ID for your region
  instance_type = "t3.medium"
  key_name = "my-key-pair"  # Replace with your key pair name
  tags = {
    Name = "nexus"
  }

  security_groups = [aws_security_group.my_sg.name]
  spot_price = "0.045"  # Replace with your desired max spot price
}
resource "aws_instance" "k8s" {
  ami = "ami-0e86e20dae9224db8"  # Ubuntu AMI ID for your region
  instance_type = "t3.medium"
  key_name = "my-key-pair"  # Replace with your key pair name
  tags = {
    Name = "k8s"
  }

  security_groups = [aws_security_group.my_sg.name]
  spot_price = "0.045"  # Replace with your desired max spot price
}

