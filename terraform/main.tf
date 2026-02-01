# This file wires everything together
# All resources are defined in their respective modules:
# - networking.tf: VPC, subnets, IGW, NAT gateways
# - security.tf: Security groups
# - alb.tf: Application Load Balancer
# - ecs.tf: ECS cluster, task definition, service
# - iam.tf: IAM roles
# - logs.tf: CloudWatch log groups

# No additional resources needed here as everything is already connected
# through resource references in the individual module files.


# module "iam" {
#   source = "../module/iam"
# }