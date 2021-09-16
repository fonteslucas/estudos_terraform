provider "aws" {
    region = "us-east-1"
}

data "aws_ecr_image" "app" {
  repository_name = var.microservicename
  image_tag       = "latest"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "cloudwatch" {
    source = "./cloudwatch"
    microservicename = var.microservicename  
}

variable "ecscluster" {
    type = string
}

variable "containernetworkmode" {
    type = string
}

variable "containerport" {
    type = number
}

variable "cpuunits" {
    type = number
}

variable "memoryreservation" {
    type = number
}

variable "memory" {
    type = number
}

variable "desiredcountservice" {
    type = number
}

variable "maxtaskcapacityasg" {
    type = number
}

variable "mintaskcapacityasg" {
    type = number
}

variable "microservicename" {
    type = string
}

resource "aws_iam_role" "service_role" {
    assume_role_policy = jsonencode ({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": ["ecs.amazonaws.com"]
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    })
    path = "/"
}

resource "aws_iam_policy" "service_policy" {
    policy = jsonencode (
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Action": [
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:Describe*",
                    "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                    "elasticloadbalancing:Describe*",
                    "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                    "elasticloadbalancing:DeregisterTargets",
                    "elasticloadbalancing:DescribeTargetGroups",
                    "elasticloadbalancing:DescribeTargetHealth",
                    "elasticloadbalancing:RegisterTargets"
                ],
                "Resource": "*"
                }
            ]
        }
    )
}

resource "aws_iam_role_policy_attachment" "service-attach" {
    role = aws_iam_role.service_role.name
    policy_arn = aws_iam_policy.service_policy.arn
}

resource "aws_iam_role" "task_role" {
    assume_role_policy = jsonencode ({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    })
    path = "/"
}

resource "aws_iam_role_policy_attachment" "task-role-attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "autoscaling_role" {
    assume_role_policy = jsonencode ({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": ["application-autoscaling.amazonaws.com"]
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    })
    path = "/"
}

resource "aws_iam_policy" "autoscaling_policy" {
    policy = jsonencode (
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Action": [
                    "application-autoscaling:*",
                    "cloudwatch:DescribeAlarms",
                    "cloudwatch:PutMetricAlarm",
                    "ecs:DescribeServices",
                    "ecs:UpdateService"
                ],
                "Resource": "*"
                }
            ]
        }
    )
}

resource "aws_ecs_task_definition" "task_definition" {
    family = var.microservicename
    network_mode = var.containernetworkmode
    requires_compatibilities = ["EC2"]
    execution_role_arn = aws_iam_role.task_role.arn
    container_definitions = jsonencode ([
        {
            "name": "${var.microservicename}",
            //This @${data.aws_ecr_image.app.image_digest} is a Workaround to force a creation of new TaskDefinition even only that changes was in the code
            "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.microservicename}:latest@${data.aws_ecr_image.app.image_digest}", 
            "cpu": "${var.cpuunits}"
            "memory" = "${var.memory}"
            "memoryreservation" = "${var.memoryreservation}"
            "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-region": "${data.aws_region.current.name}"
                "awslogs-group": "${module.cloudwatch.cloudwatch_name}"
            }
            },
            "portMappings": [
            {
                "containerPort": "${var.containerport}"
            }
            ],
            "environment": [{
            "name": "AWS_REGION",
            "value": "${data.aws_region.current.name}"
            }],
            "essential": true
    }
    ]
  )
}

resource "aws_ecs_service" "ecs_service" {
    cluster = var.ecscluster
    desired_count = var.desiredcountservice
    launch_type = "EC2"
    task_definition = aws_ecs_task_definition.task_definition.arn
    scheduling_strategy = "REPLICA"
    force_new_deployment = true
    name = var.microservicename
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent = 200
    ordered_placement_strategy {
        type = "spread"
        field = "attribute:ecs.availability-zone"  
    }
    ordered_placement_strategy {
        type = "spread"
        field = "instanceId"  
    }
}

resource "aws_appautoscaling_target" "application_auto_scaling_scalable_target" {
    max_capacity = var.maxtaskcapacityasg
    min_capacity = var.mintaskcapacityasg
    resource_id = "service/${var.ecscluster}/${aws_ecs_service.ecs_service.name}"
    role_arn = aws_iam_role.autoscaling_role.arn
    scalable_dimension = "ecs:service:DesiredCount"
    service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "add_task_policy" {
    name = "scaleup"
    policy_type = "StepScaling"
    resource_id = aws_appautoscaling_target.application_auto_scaling_scalable_target.resource_id
    scalable_dimension = aws_appautoscaling_target.application_auto_scaling_scalable_target.scalable_dimension
    service_namespace = aws_appautoscaling_target.application_auto_scaling_scalable_target.service_namespace
    step_scaling_policy_configuration {
      adjustment_type = "ChangeInCapacity"
      cooldown = 60
      metric_aggregation_type = "Maximum"
      step_adjustment {
        metric_interval_lower_bound = 0
        scaling_adjustment = 1
      }
    }
}

resource "aws_appautoscaling_policy" "remove_task_policy" {
    name = "scaledown"
    policy_type = "StepScaling"
    resource_id = aws_appautoscaling_target.application_auto_scaling_scalable_target.resource_id
    scalable_dimension = aws_appautoscaling_target.application_auto_scaling_scalable_target.scalable_dimension
    service_namespace = aws_appautoscaling_target.application_auto_scaling_scalable_target.service_namespace
    step_scaling_policy_configuration {
      adjustment_type = "ChangeInCapacity"
      cooldown = 60
      metric_aggregation_type = "Average"
      step_adjustment {
        metric_interval_upper_bound = -1
        scaling_adjustment = 1
      }
    }
}