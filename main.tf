

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}



resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "main-sravan-VPC"
  }
}

data "aws_availability_zones" "available" {}



resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-example-internet-gateway"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}



resource "aws_subnet" "main" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "public-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = element(aws_subnet.main.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "default-sg" {
  name        = "terraform_security_group"
  description = "Terraform example security group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound internet access.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "terraform-example-security-group"
  }
}




# alb security group 
resource "aws_security_group" "alb-sg" {

  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
  Name = "terraform_alb_security_group"
  }

}



resource "aws_alb" "alb" {
  name            = "terraform-example-alb"
  security_groups = ["${aws_security_group.alb-sg.id}"]
  subnets         = "${aws_subnet.main.*.id}"     ## all subnets added to the ALB 
  tags = {
    Name = "terraform-example-alb"
  }
}

#Create a new target group for the application load balancer. Traffic will be routed to target 
#web server instances on HTTP port 80. We will also define a health check for targets which will expect a "200 OK" response for the login page of our web application:
resource "aws_alb_target_group" "group" {
  name     = "terraform-example-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    #path = "/login"
    path = "/order/index.html"
    port = 80
  }
}


resource "aws_alb_target_group" "group-2" {
  name     = "terraform-alb-target-payment"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    #path = "/login"
    path = "/payment/index.html"
    port = 80
  }
}


#listener for the TG

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.group.arn}"
    type             = "forward"
  }

}

#listener rule 

resource "aws_alb_listener_rule" "static" {
  listener_arn = aws_alb_listener.listener_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.group.arn
  }

  condition {
    path_pattern {
      values = ["/order/*"]
    }
  }

}



resource "aws_instance" "server-1" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  user_data = "${file("server-script.sh")}"
  subnet_id = element(aws_subnet.main.*.id, 1)
  security_groups = ["${aws_security_group.default-sg.id}"]
  key_name = "jenkins-key-22"

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "server-2" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  user_data = file("server-script.sh")
  subnet_id = element(aws_subnet.main.*.id, 2)
  security_groups = ["${aws_security_group.default-sg.id}"]
  key_name = "jenkins-key-22"

  tags = {
    Name = "web-server-2"
  }
}

resource "aws_alb_target_group_attachment" "alb_TG_instance" {
  target_group_arn = "${aws_alb_target_group.group.arn}"
  target_id        = "${aws_instance.server-1.id}"  
  port             = 80
}


resource "aws_alb_target_group_attachment" "alb_TG_instance-2" {
  target_group_arn = "${aws_alb_target_group.group-2.arn}"
  target_id        = "${aws_instance.server-2.id}"  
  port             = 80
}


#outputs

output "subnet_name" {
  #value = aws_subnet.main.*.id
  value = aws_subnet.main.*.availability_zone
}

output "subnet-id" {
  value = aws_subnet.main.*.id
}

output "public-ip-server-1" {
  value = aws_instance.server-1.public_ip
}

output "public-ip-server-2" {
  value = aws_instance.server-2.public_ip
}