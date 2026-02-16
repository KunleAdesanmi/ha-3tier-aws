# This is a Terraform configuration file that sets up a 3-tier architecture with high availability (HA) in AWS.
# It uses modules to create a VPC and subnets, and configures the AWS provider. The configuration is designed to be reusable and customizable through input variables.


# configure aws provider
provider "aws" {
  region  = var.region
  profile = "default"
}

# create a VPC
module "vpc" {
  source                       = "./modules/vpc"
  region                       = var.region
  project_name                 = var.project_name
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

# create security groups
module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}


// -------------------------
// Web Tier Auto Scaling Group
// -------------------------

resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = var.web_ami_id // e.g., an AMI for your web tier
  instance_type = var.web_instance_type
  // ...additional configuration (e.g., security groups, key name)...
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name_prefix      = "${var.project_name}-web-asg-"
  max_size         = var.web_asg_max_size
  min_size         = var.web_asg_min_size
  desired_capacity = var.web_asg_desired_capacity
  vpc_zone_identifier = [
    module.vpc.public_subnet_az1_id,
    module.vpc.public_subnet_az2_id
  ]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-instance"
    propagate_at_launch = true
  }
}


// -------------------------
// App Tier Auto Scaling Group
// -------------------------
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = var.app_ami_id // e.g., an AMI for your app tier
  instance_type = var.app_instance_type
  // ...additional configuration...
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name_prefix      = "${var.project_name}-app-asg-"
  max_size         = var.app_asg_max_size
  min_size         = var.app_asg_min_size
  desired_capacity = var.app_asg_desired_capacity
  vpc_zone_identifier = [
    module.vpc.private_app_subnet_az1_id,
    module.vpc.private_app_subnet_az2_id
  ]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-instance"
    propagate_at_launch = true
  }
}

# application load balancer and target group or listener

resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc.public_subnet_az1_id, module.vpc.public_subnet_az2_id]
  security_groups    = [module.security_groups.alb_sg]
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

// -------------------------
// ECS Cluster, Task Definition & Service (Fargate)
// -------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = var.ecs_execution_role
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.app_container_image
      cpu       = var.ecs_container_cpu
      memory    = var.ecs_container_memory
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name             = "${var.project_name}-service"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.app_task.arn
  desired_count    = var.ecs_desired_count
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  network_configuration {
    subnets = [
      module.vpc.private_app_subnet_az1_id,
      module.vpc.private_app_subnet_az2_id
    ]
    assign_public_ip = false
    security_groups  = [var.ecs_service_security_group_id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "app"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.app_listener]
}

# Aurora MySQL Cluster with writer and reader instances

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "${var.project_name}-aurora-subnet-group"
  description = "Subnet group for Aurora MySQL cluster"
  subnet_ids = [
    module.vpc.private_data_subnet_az1_id,
    module.vpc.private_data_subnet_az2_id
  ]
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "${var.project_name}-aurora-cluster"
  engine                 = "aurora-mysql"
  master_username        = var.db_username
  master_password        = var.db_password
  database_name          = var.db_name
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  engine_mode            = "provisioned"
}

resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${var.project_name}-aurora-writer"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible = false
}

resource "aws_rds_cluster_instance" "reader" {
  count               = var.db_reader_count
  identifier          = "${var.project_name}-aurora-reader-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible = false
}
