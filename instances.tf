#--------ELB------------

resource "aws_elb" "eshop-elb" {
  name            = "eshop-elb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.webservers.id]

  listener {
    instance_port     = 5106
    instance_protocol = "http"
    lb_port           = 5106
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 5200
    instance_protocol = "http"
    lb_port           = 5200
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
  count                  = length(var.subnets_cidr)
  ami                    = var.webservers_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.webservers.id]
  subnet_id              = element(aws_subnet.public.*.id, count.index)
  key_name               = "eshop-key"
  user_data              = file("./init.sh")

  tags = {
    Name = "Server-${count.index}"
  }
}

output "elb-dns-name" {
  value = aws_elb.eshop-elb.dns_name
}