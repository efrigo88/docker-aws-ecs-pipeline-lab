data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Owner ID is Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
output "ubuntu_ami_data" {
  value = data.aws_ami.ubuntu.id
}

resource "aws_instance" "chroma_db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.chroma_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.chroma_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Download init script from S3
              aws s3 cp s3://${aws_s3_bucket.scripts.id}/init-chroma.sh /tmp/init-chroma.sh
              chmod +x /tmp/init-chroma.sh
              /tmp/init-chroma.sh
              EOF

  tags = {
    Name = "chroma-db-instance"
  }
}

# Security Group for Chroma DB
resource "aws_security_group" "chroma_sg" {
  name        = "chroma-security-group"
  description = "Security group for Chroma DB"
  vpc_id      = aws_vpc.main.id

  # Allow inbound traffic from ECS tasks only
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  # Allow outbound traffic to S3 and other AWS services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "chroma-security-group"
  }
}
