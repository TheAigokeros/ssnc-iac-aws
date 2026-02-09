# SS&C AWS Infrastructure as Code

This repository contains Terraform infrastructure as code for provisioning a containerized application on AWS. This implementation demonstrates a basic, easy-to-read Terraform design pattern suitable for testing and evaluation purposes.

## Overview

This infrastructure provisions a production-ready containerized application stack on AWS using:
- **Amazon ECS (Fargate)** for container orchestration
- **Application Load Balancer (ALB)** for traffic distribution
- **VPC** with public and private subnets across multiple availability zones
- **Auto Scaling** based on CPU utilization
- **CloudWatch** for monitoring and logging
- **SNS** for alerting

## Design Pattern

This implementation follows a **flat, easy-to-read structure** where all resources are organized by function in separate files. This approach prioritizes clarity and maintainability for testing and evaluation purposes.

**Note:** In a production environment, this infrastructure would typically be organized into:
- Separate modules for reusability
- Environment-specific configurations (dev, staging, prod)
- Remote state management with S3 backend
- Workspace-based or directory-based environment separation

## Architecture

The infrastructure deploys a containerized application with the following architecture:

```
Internet
   │
   ▼
Application Load Balancer (Public Subnets)
   │
   ▼
ECS Service (Private Subnets)
   │
   ├── ECS Tasks (Fargate)
   └── Auto Scaling (CPU-based)
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions
- Docker image available in ECR or Docker Hub

## AWS Services Provisioned

The following table outlines all AWS services and resources provisioned by this Terraform configuration:

| Category | Service/Resource | Count | Description |
|----------|-----------------|-------|-------------|
| **Networking** | VPC | 1 | Virtual Private Cloud with DNS support |
| | Internet Gateway | 1 | Gateway for internet access |
| | Public Subnets | 2 | Subnets across 2 AZs for public-facing resources |
| | Private Subnets | 2 | Subnets across 2 AZs for application workloads |
| | Route Tables | 3 | 1 public + 2 private route tables |
| | NAT Gateways | 2 | Network Address Translation for private subnet internet access |
| | Elastic IPs | 2 | Static IPs for NAT Gateways |
| **Compute** | ECS Cluster | 1 | Container orchestration cluster with Container Insights |
| | ECS Task Definition | 1 | Container task definition (Fargate) |
| | ECS Service | 1 | ECS service managing task lifecycle |
| | Application Auto Scaling Target | 1 | Auto scaling configuration (min: 2, max: 4 tasks) |
| | Application Auto Scaling Policy | 1 | CPU-based scaling policy (target: 60% CPU) |
| **Load Balancing** | Application Load Balancer | 1 | HTTP/HTTPS load balancer |
| | Target Group | 1 | Target group for ECS tasks with health checks |
| | ALB Listener | 1 | HTTP listener on port 80 |
| **Security** | Security Group (ALB) | 1 | Security group allowing HTTP/HTTPS from internet |
| | Security Group (ECS Tasks) | 1 | Security group allowing traffic from ALB only |
| **IAM** | IAM Role (Task Execution) | 1 | Role for ECS task execution with CloudWatch Logs permissions |
| | IAM Role (Task) | 1 | Role for application-level permissions |
| | IAM Policy Attachment | 1 | Attaches AWS managed policy for task execution |
| **Monitoring & Logging** | CloudWatch Log Group | 1 | Log group for ECS container logs (7-day retention) |
| | CloudWatch Metric Alarm | 1 | Alarm for ALB 5xx errors |
| **Notifications** | SNS Topic | 1 | Topic for alert notifications |
| | SNS Topic Subscription | 1 | Email subscription for alerts |

## Project Structure

```
terraform/
├── backend.tf          # Terraform backend configuration (optional S3 backend)
├── provider.tf         # AWS provider configuration with default tags
├── versions.tf         # Terraform and provider version constraints
├── main.tf             # Main configuration file
├── variables.tf        # Input variables with defaults
├── outputs.tf          # Output values (VPC ID, ALB DNS, ECS cluster info, etc.)
├── networking.tf       # VPC, subnets, Internet Gateway, NAT Gateways
├── security.tf         # Security groups for ALB and ECS tasks
├── alb.tf              # Application Load Balancer, listener, target group
├── ecs.tf              # ECS cluster, task definition, service, auto scaling
├── iam.tf              # IAM roles for ECS task execution and tasks
├── logs.tf             # CloudWatch log group
├── alarms.tf            # CloudWatch metric alarms
└── sns.tf               # SNS topic and subscriptions for alerts
```

## Configuration

### Variables

Key variables can be customized in `terraform/variables.tf` or via `terraform.tfvars`:

- `aws_region`: AWS region (default: `ap-southeast-1`)
- `aws_profile`: AWS profile name (default: `poc_ssnc`)
- `environment`: Environment name (default: `development`)
- `project_name`: Project name for resource naming (default: `ssnc`)
- `container_image`: Docker image URL (default: `nginx:latest`)
- `container_port`: Container port (default: `8080`)
- `desired_count`: Initial number of ECS tasks (default: `3`)
- `alert_email`: Email for SNS alerts (default: `xxx@example.com`)

### Example: Using tfvars file

Create a `terraform.tfvars` file or use the provided `non-prod.tfvars`:

```hcl
aws_region     = "ap-southeast-1"
environment    = "staging"
container_image = "your-account.dkr.ecr.ap-southeast-1.amazonaws.com/hello-world:xxx"
alert_email    = "your-email@example.com"
```

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Plan Infrastructure Changes

```bash
terraform plan -var-file=non-prod.tfvars -out=plan.out
```

### Apply Infrastructure

```bash
terraform apply plan.out
```

Or apply directly:

```bash
terraform apply -var-file=non-prod.tfvars
```

### View Outputs

After deployment, view the outputs:

```bash
terraform output
```

Key outputs include:
- `alb_dns_name`: DNS name of the load balancer
- `ecs_cluster_name`: Name of the ECS cluster
- `vpc_id`: VPC ID

### Other Useful Commands

```bash
# List all resources in state
terraform state list

# Show resource details
terraform state show <resource_address>

# Destroy infrastructure
terraform destroy -var-file=non-prod.tfvars
```

## Default Configuration

- **Region**: `ap-southeast-1` (Singapore)
- **Availability Zones**: `ap-southeast-1a`, `ap-southeast-1b`
- **VPC CIDR**: `10.0.0.0/16`
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Private Subnets**: `10.0.10.0/24`, `10.0.20.0/24`
- **ECS Tasks**: 3 tasks (auto-scales between 2-4 based on CPU)
- **Container Resources**: 256 CPU units (0.25 vCPU), 512 MB memory

## Auto Scaling

The ECS service is configured with automatic scaling:
- **Minimum capacity**: 2 tasks
- **Maximum capacity**: 4 tasks
- **Scaling metric**: CPU utilization
- **Target CPU**: 60%

## Monitoring & Alerts

- **CloudWatch Logs**: Container logs are sent to CloudWatch with 7-day retention
- **CloudWatch Alarms**: ALB 5xx errors trigger alerts
- **SNS Notifications**: Alerts are sent via email to the configured address

## Security Features

- ECS tasks run in private subnets (no direct internet access)
- Security groups restrict traffic to necessary ports only
- ALB security group allows HTTP/HTTPS from internet
- ECS task security group only allows traffic from ALB
- IAM roles follow least privilege principles

## Notes

- This is a test/evaluation implementation using a flat structure for clarity
- For production use, consider:
  - Modularizing the codebase
  - Implementing environment-specific configurations
  - Using remote state backend (S3)
  - Adding additional monitoring and alerting
  - Implementing CI/CD pipelines
  - Adding backup and disaster recovery strategies

## License

This is a test implementation for SS&C evaluation purposes.
