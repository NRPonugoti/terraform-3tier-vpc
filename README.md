# Terraform 3-Tier VPC on AWS

This folder implements the full 3-tier architecture from the plan:

- Web tier in public subnets with ALB
- App tier in private subnets
- DB tier (RDS) in isolated private subnets

## Resources created

- 1 VPC (`10.0.0.0/16`)
- 6 subnets (2 web public, 2 app private, 2 db private)
- 1 Internet Gateway
- 1 NAT Gateway + 1 Elastic IP
- 3 route tables
- 3 security groups
- 2 web EC2 instances + 1 ALB + target group + listener
- 2 app EC2 instances
- 1 RDS instance + DB subnet group

## Prerequisites

- Terraform >= 1.5
- AWS account and credentials configured (`aws configure` or environment variables)
- Existing EC2 key pair in selected region

## Deploy

1. Copy the example vars file:

   `cp terraform.tfvars.example terraform.tfvars`

2. Edit `terraform.tfvars`:

   - Set `admin_cidr` to your public IP in `/32` format
   - Set `key_name` to an existing key pair
   - Set strong `db_password`

3. Initialize Terraform:

   `terraform init`

4. Review changes:

   `terraform plan`

5. Apply:

   `terraform apply`

## Verify (Step 10)

After apply, use the outputs:

`terraform output`

### Web tier check

- Open `alb_dns_name` in browser (`http://<alb_dns_name>`)
- You should see response from web server 1 or 2

### App tier check via bastion-style hop

1. SSH to web instance:
   `ssh -i <key>.pem ec2-user@<web_public_ip>`
2. From web instance, SSH to app instance private IP:
   `ssh -i <key>.pem ec2-user@<app_private_ip>`
3. Confirm outbound internet via NAT from app instance:
   `curl https://checkip.amazonaws.com`

### DB connectivity check from app instance

1. Install MySQL client:
   `sudo yum install -y mysql`
2. Connect to DB:
   `mysql -h <rds_endpoint> -u admin -p`

### Isolation checks

- App instances are not directly internet reachable
- DB is not publicly accessible
- DB traffic is allowed only from app security group

## Cleanup

Destroy resources to avoid charges:

`terraform destroy`

Note: NAT Gateway and RDS can incur charges if left running.
