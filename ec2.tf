


resource "aws_instance" "server-1" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  #user_data = "${file("server-script.sh")}"
  subnet_id = element(aws_subnet.main.*.id, 0)
  security_groups = ["${aws_security_group.default-sg.id}"]
  key_name = "jenkins-key-22"

  user_data = <<-EOF
              
              
              #!/bin/bash
              sudo yum update
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd
              mkdir -p /var/www/html/order
              touch /var/www/html/order/index.html
              echo -e "<h1>Hello from Terraform, this is created by SRAVAN, `hostname -f` </h1>" >>sudo tee /var/www/html/order/index.html
              sudo systemctl restart httpd
              EOF

  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "server-2" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  #user_data = file("server-script.sh")
  subnet_id = element(aws_subnet.main.*.id, 1)
  security_groups = ["${aws_security_group.default-sg.id}"]
  key_name = "jenkins-key-22"
  user_data = <<-EOF
              
              
              #!/bin/bash
              sudo yum update
              sudo yum install -y httpd
              sudo systemctl enable httpd
              sudo systemctl start httpd
              mkdir -p /var/www/html/payment
              touch /var/www/html/payment/index.html
              echo -e "<h1>Hello from Terraform, this is created by SRAVAN, this is PAYMENT, `hostname -f` </h1>" >>sudo tee /var/www/html/order/index.html
              sudo systemctl restart httpd
              EOF

  tags = {
    Name = "web-server-2"
  }
}


resource "aws_instance" "server-3" {
  ami = "ami-04ad2567c9e3d7893"
  instance_type = "t2.micro"
  user_data = file("server-script.sh")
  subnet_id = element(aws_subnet.main.*.id, 3)
  security_groups = ["${aws_security_group.default-sg.id}"]
  key_name = "jenkins-key-22"
  

  tags = {
    Name = "web-server-3"
  }
}