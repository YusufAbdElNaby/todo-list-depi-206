# Variables
variable "ami_id" {
  default = "ami-04a92520784b93e73"  # AMI ID
}

variable "instance_type" {
  default = "t3a.medium"  # Instance type
}

variable "key_name" {
  default = "Jenkins-t"  # KeyPair name
}

# Security Group for Jenkins Server
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main.id
  name   = "Jenkins-SG"

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Jenkins (8080) from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Sonarqub (9000) from anywhere
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

# Elastic IP for Jenkins EC2
resource "aws_eip" "jenkins_eip" {
  domain = "vpc"  # This replaces the deprecated 'vpc = true'
}

# EC2 instance for Jenkins Server
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type         = var.instance_type
  key_name               = var.key_name
  subnet_id             = aws_subnet.public_subnet_a.id  # Use the public subnet in eu-west-3a
  associate_public_ip_address = true  # Associate public IP address

  # Root volume configuration
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  # Security group association
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # Assign the Elastic IP
  depends_on = [aws_eip.jenkins_eip]

  # Tags
  tags = {
    Name = "Jenkins-EC2"
  }
}

# Elastic IP Association
resource "aws_eip_association" "jenkins_eip_association" {
  instance_id = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins_eip.id
}
