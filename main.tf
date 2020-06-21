provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  tags = var.default_tags
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
}

# Create a new load balancer
resource "aws_elb" "elastic-load-balancer" {
  #availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]

  # access_logs {
  #   bucket        = "foo"
  #   bucket_prefix = "bar"
  #   interval      = 60
  # }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = ["${aws_instance.web-instance-a.id}", "${aws_instance.web-instance-b.id}", "${aws_instance.web-instance-c.id}"]
  subnets = ["${aws_subnet.public-subnet-a.id}", "${aws_subnet.public-subnet-b.id}", "${aws_subnet.public-subnet-c.id}"]
  security_groups = ["${aws_security_group.web-instance-security-group.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = var.default_tags
}


resource "aws_subnet" "public-subnet-a" {
  tags = var.default_tags
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-a
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "public-subnet-b" {
  tags = var.default_tags
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-b
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "public-subnet-c" {
  tags = var.default_tags
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-c
  availability_zone = "${var.region}c"
}

resource "aws_route_table" "public-subnet-route-table" {
  tags = var.default_tags
  vpc_id = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "igw" {
  tags = var.default_tags
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association-a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association-c" {
  subnet_id      = aws_subnet.public-subnet-c.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_key_pair" "web" {
  tags = var.default_tags
  public_key = file(pathexpand(var.public_key))
}

resource "aws_instance" "web-instance-a" {
  tags = var.default_tags
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.web-instance-security-group.id]
  subnet_id                   = aws_subnet.public-subnet-a.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web.key_name
  user_data                   = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

}

resource "aws_instance" "web-instance-b" {
  tags = var.default_tags
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.web-instance-security-group.id]
  subnet_id                   = aws_subnet.public-subnet-b.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web.key_name
  user_data                   = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

}

resource "aws_instance" "web-instance-c" {
  tags = var.default_tags
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.web-instance-security-group.id]
  subnet_id                   = aws_subnet.public-subnet-c.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web.key_name
  user_data                   = <<EOF
#!/bin/sh
yum install -y nginx
service nginx start
EOF

}

resource "aws_security_group" "web-instance-security-group" {
  tags = var.default_tags
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

output "web_domain" {
  value = aws_elb.elastic-load-balancer
}

