ECS DEPLOY WITH TERRAFORM

Create, using the automation language you prefer (CloudFormation, Terraform, Python, Bash,
etc) aAWS ECS stack so composed:
● VPC
    ○ 2 public subnet
    ○ 2 private subnet
○ 1 bastion host (ami linux free tyre access)
○ Internet gateway
○ Nat gateway
● 1 ALB in VPC
    ○ Default ACM certificate ARN as parameter ( (env file or user provided)
    ○ http redirects on https on default (ALB SSL termination)
● 1 ECS CLuster
● 1 Service defined on cluster on private subnet with:
○ A specific execution role
○ A target group linked to ALB on a parametric (env file or user provided) web
address
○ Logs on cloudwatch
● 1 standard nginx task running on fargate (a simple task definition)
● 1 EFS FS for website contents mounted in container
● Pipeline (bitbucket / github / gitlab) with 3 deployment environments (dev, test, prod)


AS per above tasks all infra has been deployed with terraform,
I have used terraform module having 5 module as like
  VPC
  Security Group
  EC2
  ALB
  ECS_Fargate

With ALB module i have just used http not https as i have not domain name to create valid ACM ssl. So terraform will not work without valid ACM.
I have commented out that https listiner section it can be used later if we have valid domian.

To deploy this infra i have used github actions for CICD to provision in 3 different environment with 3 different aws accounts.
In the Directory .github/workflows there is file called infra-pipeline.yml which is used for infra provisioning.

To run this pipeline you should have 
github account and repo name terraform-ecs-infra
3 branch dev, stage & prod (branch name should be exact same)
3 different secrects created for AWS Credentials 
   AWS_DEV_ACCESS_KEY
   AWS_DEV_SECRET_KEY
   AWS_STAGE_ACCESS_KEY
   AWS_STAGE_SECRET_KEY
   AWS_PROD_ACCESS_KEY
   AWS_PROD_SECRET_KEY
In all 3 AWS ACCOUNT create key pairs for ec2 bastion ssh, the naming should be exact same as like
  Dev-BastionAccessInstanceKey
  Stage-BastionAccessInstanceKey 
  Prod-BastionAccessInstanceKey
  or you can use own your naming and update in *.tfvars file
Update Instance AMI id as per your account and region selected.
tune *.tfvars file as per your requirements.
With aws region us-east-1 create these two s3 bucket and dynamodb table
    bucket         = "devops-challenge-tasks-terraform-state"
    dynamodb_table = "devops-challenge-dynamodb-state-lock"


In terraform module it will pickup tfvars file as per branch name. Change the value of tfvars as per your infra requirements.
We have mounted nginx configuration with efs volumes, so you need to update server name in nginx conf, its located at
ecs_terraform/nginx-conf/default.conf
If you want to change config further later,i have created EC2 bastion host that is NFS mounted with EFS.
in that EC2 there is directory called mount-ecs  so in this directory any container volumes can mounted and nginx config is aswell mounted and you can update from there.

So finally git push this code as per branch selected then it will provision ecs infra with selected env.

----------------***********--------------**************-------------
CICD APP DEPLOY IN ECS
I have created another github repo for application codes and its cicd using github actions.
Created Dockerfile , that will build docker image for application source codes.
Application codes is just for static website 

In cicd pipeline it will first build the docker image form source codes and it will push to ECR repo. Then finally it will deploy updated image to ECS cluster.

To run this pipeline you must first have

Github account and application repo name ecs-deploy-tf.
Secrets created in github repo as like
   DEV_ECS_AWS_ACCESS_KEY
   DEV_ECS_AWS_SECRECT_KEY
   STAGE_ECS_AWS_ACCESS_KEY
   STAGE_ECS_AWS_SECRECT_KEY
   PROD_ECS_AWS_ACCESS_KEY
   PROD_ECS_AWS_SECRECT_KEY
UPDATE pipeline code in line no 10 and update with your github account.Filename and its location
   .github/workflows/pipeline.yml
   like DevilHost069/terraform-ecs-infra/.github/workflows/ecs-deploy-pipeline.yml@stage  update DevilHost069 with your account

Also change in line no 20 & 21 as per branch and env like i have used stage aws keys

In that pipeline i have reusuable workflow that will call another workflow pipeline located at
    DevilHost069/terraform-ecs-infra/.github/workflows/ecs-deploy-pipeline.yml@stage
this file path will remain same in every environment branch name as that will be used by other workflow pipeline.


So finally git push the codes it will deploy to ecs cluster with updated image tag.







