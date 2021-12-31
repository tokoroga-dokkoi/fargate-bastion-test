data "aws_iam_role" "execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_policy_document" "task_ssm" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ssm.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DeleteActivation",
      "ssm:RemoveTagsFromResource",
      "ssm:AddTagsToResource",
      "ssm:CreateActivation"
    ]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "bastion_task" {
  name = "ecs-bastion-test-task-policy"
  path = "/"
  policy = data.aws_iam_policy_document.task_ssm.json
}

module "bastion_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  create_role = true
  role_name = "ecs-bastion-test-task-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    aws_iam_policy.bastion_task.arn
  ]
}

// ECS TaskがSystems Managerに渡すIAMロール
data "aws_iam_policy" "ssm_managed_instance_core" {
  name = "AmazonSSMManagedInstanceCore"
}
module "bastion_ssm_pass_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  trusted_role_services = [
    "ssm.amazonaws.com"
  ]

  create_role = true
  role_name = "ecs-bastion-task-ssm-pass-role"
  role_requires_mfa = false

  custom_role_policy_arns = [
    data.aws_iam_policy.ssm_managed_instance_core.arn
  ]
}

data "template_file" "bastion_task_definition" {
  template = file("${path.module}/task_template/bastion_task_definition.yml.tpl")
  vars = {
    bastion_image_url = "${aws_ecr_repository.bastion.repository_url}:bastion"
  }
}

resource "aws_ecs_task_definition" "bastion" {
  family = "bastion-task"
  container_definitions = jsonencode(yamldecode(data.template_file.bastion_task_definition.rendered))
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  task_role_arn = module.bastion_task_role.iam_role_arn
  execution_role_arn = data.aws_iam_role.execution_role.arn
}

module "bastion_ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  name = "bastion-ecs-cluster"

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [{
    capacity_provider = "FARGATE"
    weight = 1
  }]
}
