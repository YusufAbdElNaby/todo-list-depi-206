# Variables


variable "instance_type_bastion" {
  default = "t2.micro"  # Instance type
}



# Security Group for Jenkins Server
resource "aws_security_group" "bastion-host-sg" {
  vpc_id = aws_vpc.main.id
  name   = "bastion-host-SG"

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "bastion-host-SG"
  }
}

# Elastic IP for bastion-host EC2
resource "aws_eip" "bastion-host_eip" {
  domain = "vpc"  # This replaces the deprecated 'vpc = true'
}

# EC2 instance for Jenkins Server
resource "aws_instance" "bastion-host" {
  ami                    = var.ami_id
  instance_type         = var.instance_type_bastion
  key_name               = var.key_name
  subnet_id             = aws_subnet.public_subnet_a.id  # Use the public subnet in eu-west-3a
  associate_public_ip_address = true  # Associate public IP address

  # Root volume configuration
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # Security group association
  vpc_security_group_ids = [aws_security_group.bastion-host-sg.id]

  # Assign the Elastic IP
  depends_on = [aws_eip.bastion-host_eip]

  # Tags
  tags = {
    Name = "bastion-host-EC2"
  }
}

# Elastic IP Association
resource "aws_eip_association" "bastion-host_eip_association" {
  instance_id = aws_instance.bastion-host.id
  allocation_id = aws_eip.bastion-host_eip.id
}
