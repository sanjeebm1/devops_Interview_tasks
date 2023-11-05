project = "DevOps_Challenge_ECS"
createdBy = "DevOpsoNe"
aws_region      = "us-east-1"
profile         = "oNe"
prod-profile    = "mfa"
environment     = "prod"


#VPC
cidr                 = "10.200.0.0/16"
vpc_name             = "VPC_DevOps_Challenge"
igw_tag              = "IGW_DevOps_Challenge"
enable_dns_support = true
enable_dns_hostnames = true
public_subnets_cidr  = ["10.200.1.0/24", "10.200.2.0/24"]
private_subnets_cidr = ["10.200.3.0/24", "10.200.4.0/24"]
availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]


#BASTION EC2
instance_ami = "ami-053b0d53c279acc90" # Update as per your regions
instance_type = "t2.micro"

volume_size = "25"
key_name = "Prod-BastionAccessInstanceKey"
pre_assign_privateip = "10.200.1.100"
private_key_path = "./private-key/Prod-BastionAccessInstanceKey.pem"
## Security Group
remote_sg = {
  "22" = ["10.200.0.0/16","103.94.255.87/32"]
}
nginx_sg_ecs = {
  "80" = ["10.200.1.100/32"],
  "8000" = ["10.200.1.100/32"]
}
backend_alb_sg = {
  "80"   = ["0.0.0.0/0"],
  "443"   = ["0.0.0.0/0"],
}

### ALB #####
alb_name = "challenge-ecs-alb"
target_type = "ip"
targetgroup_name = "challenge-tg-ecs-alb"
bucket_name = "challenge-ecs-alb-access-logs"
acm_arn = "arn:aws:acm:us-east-1:893117704213:certificate/36457d7f-1e6d-47b4-8a9e-dcff277ecfe6"

### ECS ####
services-ecs = "challenge-servicediscovery"
ecs_cluster_name = "challenge-ecs-fargate"
task_nginx = "nginx"
svc_name = "nginx-service"
nginx-config = "nginx-config"
nginx-html = "nginx-html"
app_desired_count = "2"
capacity_provider1 = "FARGATE_SPOT"
capacity_provider2 = "FARGATE"
container_name = "gymapp-nginx"
container_port = "80"
target_value_cpu = "80"
target_value_memory = "85"
max_capacity = "5"
min_capacity = "2"
nginx-memory = "1024"
nginx-cpu = "512"
efs_volumes = {
    "nginx-config"="/nginx/config"
}