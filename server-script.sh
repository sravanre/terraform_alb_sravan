#!/bin/bash
sudo yum update
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
mkdri -p /var/www/html/order
echo -e "<h1>Hello from Terraform, this is created by SRAVAN, $(hostname -f)</h1>" >>sudo tee /var/www/html/order/index.html
sudo systemctl restart httpd


