# terraform_alb_sravan
terraform alb , ASg , ec2 ,  infrastructure code with deployment


terraform init
terraform plan
terraform apply -auto-approve


output : sravan@LAPTOP-3F1CCKM8:/mnt/c/Users/Sravan/Documents/terraform_newcodeCamp/alb_ec2$ terraform state list
data.aws_availability_zones.available
aws_alb.alb
aws_alb_listener.listener_http
aws_alb_listener_rule.static
aws_alb_target_group.group
aws_alb_target_group.group-2
aws_alb_target_group_attachment.alb_TG_instance
aws_alb_target_group_attachment.alb_TG_instance-2
aws_instance.server-1
aws_instance.server-2
aws_instance.server-3
aws_internet_gateway.gateway
aws_route_table.public_rt
aws_route_table_association.route_table_association[0]
aws_route_table_association.route_table_association[1]
aws_route_table_association.route_table_association[2]
aws_route_table_association.route_table_association[3]
aws_route_table_association.route_table_association[4]
aws_route_table_association.route_table_association[5]
aws_security_group.alb-sg
aws_security_group.default-sg
aws_subnet.main[0]
aws_subnet.main[1]
aws_subnet.main[2]
aws_subnet.main[3]
aws_subnet.main[4]
aws_subnet.main[5]
aws_vpc.vpc



