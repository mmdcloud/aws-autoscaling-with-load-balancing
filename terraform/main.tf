# # Calling "VPC" module
# module "vpc" {
#   source = "./vpc"
# }

# # Calling "Security Groups" module
# module "sg" {
#   source = "./security-groups"
#   vpcid  = module.vpc.vpcid
# }

# # Calling "Launch Template" module
# module "launch-template" {
#   source = "./launch-template"
#   asgid  = module.sg.asgid
# }

# # Calling "CodeCommit" module
# module "codecommit" {
#   source = "./codecommit"
# }

# # Calling "CodeBuild" module
# module "codebuild" {
#   source            = "./codebuild"
#   codecommitRepoUrl = module.codecommit.codecommitRepoUrl
# }

# # Calling "CodeDeploy" module
# module "codedeploy" {
#   source = "./codedeploy"
# }

# # Calling "CodePipeline" module
# module "codepipeline" {
#   source = "./codepipeline"
# }


# # Calling "Load Balancer" module
# module "lb" {
#   source         = "./load-balancer"
#   vpcid          = module.vpc.vpcid
#   lbsgid         = module.sg.lbsgid
#   public_subnets = module.vpc.public_subnets
# }

# # Calling "Auto Scaling Group" module
# module "asg" {
#   source           = "./auto-scaling-groups"
#   public_subnets   = module.vpc.public_subnets
#   target_group_arn = module.lb.target_group_arn
#   launchTemplateId = module.launch-template.launchTemplateId
# }

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route table"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "asg" {
  name   = "asg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
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

resource "aws_security_group" "lb" {
  name   = "lb"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_launch_template" "nodejs_template" {
  name = "nodejs_template"

  description = "Sample Node.js App !"

  image_id = "ami-0a0e5d9c7acc336f1"

  instance_type = "t2.micro"

  key_name = "surajm"

  ebs_optimized = false

  instance_initiated_shutdown_behavior = "stop"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.asg.id]
  }
  user_data = filebase64("${path.module}/../scripts/user_data.sh")
}

resource "aws_lb" "lb" {
  name                       = "lb"
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  tags = {
    Name = "lb"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name            = "lb-target-group"
  port            = 80
  ip_address_type = "ipv4"
  protocol        = "HTTP"

  vpc_id = aws_vpc.vpc.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    port                = 80
  }

  tags = {
    Name = "lb_target_group"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}


resource "aws_autoscaling_group" "asg" {
  name                      = "ASG"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
  vpc_zone_identifier       = aws_subnet.public_subnets[*].id
  launch_template {
    id      = aws_launch_template.nodejs_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }
}
