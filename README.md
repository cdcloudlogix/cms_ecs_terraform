# WordPress ECS Fargate and Terraform

## What is cms_ecs_terraform?
A simple proof of concept deploying from A to Z:
* All the necessary Network components
* ECS Cluster
* RDS MySql instance
* Application Load Balancing

This project is leveraging Terraform for deploying all necessary components

## News
* 2019-10-13 - v0.0.1 released! [[download](https://github.com/cdcloudlogix/cms_ecs_terraform/releases/tag/0.0.1)]

## Prerequisites
* Access to an AWS Account
* [Terraform v0.12.10](https://www.terraform.io/downloads.html)
* [AWS Credentials](https://www.terraform.io/docs/providers/aws/index.html)
* S3 Bucket for configuring Terraform backend

Make sure that your AWS Credentials does have AdministratorAccess level to be able to run this Terraform plan.

## Quick Start
Once you've created a new S3 Bucket, replace the name of this bucket in the `backend "s3"` section.
Then, run the following command to initialise Terraform:
`terraform init`

Follow by apply:
`terraform apply`

Just reply `yes` if you're happy with the configuration and changes.
This plan would run in `eu-west-1` and use the `10.2.0.0/16` network by default. Don't hesitate to modify these values based on your need.

## Verify
After applying your changes, do the following command:
`terraform show | grep dns_name`

Collect the url, and you should be able to display Wordpress initial page.

## Cleanup
The following command would allow you to cleanup your environment once you completed your testing:
`terraform destroy`
