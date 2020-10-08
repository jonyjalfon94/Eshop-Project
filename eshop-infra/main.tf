# VPC
resource "aws_vpc" "eshop_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "EshopVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eshop_igw" {
  vpc_id = aws_vpc.eshop_vpc.id
  tags = {
    Name = "main"
  }
}

# Subnets : public
resource "aws_subnet" "public" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.eshop_vpc.id
  cidr_block              = element(var.subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

# Route table: attach Internet Gateway 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eshop_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eshop_igw.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

#-----Security-Groups------------

resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.eshop_vpc.id

  ingress {
    from_port   = 5106
    to_port     = 5106
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------ELB------------

# Create a new load balancer
resource "aws_elb" "eshop-elb" {
  name = "eshop-elb"
  #availability_zones = ["${var.azs}"]
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.webservers.id]

  listener {
    instance_port     = 5106
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5106/"
    interval            = 30
  }

  instances                   = aws_instance.webservers.*.id
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "eshopform-elb"
  }
}

#--------Instances-----------

resource "aws_instance" "webservers" {
  count           = length(var.subnets_cidr)
  ami             = var.webservers_ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.webservers.id]
  subnet_id       = element(aws_subnet.public.*.id, count.index)
  key_name = "eshop-key"
#   user_data = "${file("init.sh")}"

  tags = {
    Name = "Server-${count.index}"
  }
}


output "elb-dns-name" {
  value = aws_elb.eshop-elb.dns_name
}