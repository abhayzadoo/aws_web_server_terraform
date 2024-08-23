

# creaating vpc
resource "aws_vpc" "my_web_server_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_web_server_vpc"
  }
}

# create a public subnet 

resource "aws_subnet" "my_web_server_subnet" {
  vpc_id = aws_vpc.my_web_server_vpc.id

  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "my_web_server_subnet"
  }
}

# create internet gateway

resource "aws_internet_gateway" "my_web_server_ig" {
  vpc_id = aws_vpc.my_web_server_vpc.id

  tags = {
    Name = "my_web_server_ig"
  }
}

# create a route table

resource "aws_route_table" "my_webs_server_rt" {
  vpc_id = aws_vpc.my_web_server_vpc.id

  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_server_ig.id
  }
  tags = {
    Name = "my_webs_server_rt"
  }
}

#assocate the route table with subnet 

resource "aws_route_table_association" "my_web_server_rt_assc" {
  subnet_id      = aws_subnet.my_web_server_subnet.id
  route_table_id = aws_route_table.my_webs_server_rt.id
}

# create secutiry group that allows HTTp and ssh traffic

resource "aws_security_group" "my_web_server_sg" {
  vpc_id = aws_vpc.my_web_server_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create ec2 instance within the vpc ans subnet

resource "aws_instance" "my_web_server" {
  ami           = var.ami
  instance_type = "t2.micro"

  # associate security group and subnet 
  vpc_security_group_ids = [aws_security_group.my_web_server_sg.id]
  subnet_id              = aws_subnet.my_web_server_subnet.id

  #user data to install and start web server

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "Hello, World!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "my_web_server"
  }
}
