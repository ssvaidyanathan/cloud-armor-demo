# Cloud Armor Demo

## Pre-Requisites
- Google Cloud Account 
- Billing Account
- Google Cloud Project

## Installations
- gcloud SDK
- Terraform

## Steps
- In your terminal, run `gcloud auth application-default login`
- Run `gcloud init` and set the gcloud config to your GCP project
- Update the project_id variable in the terraform.tfvars file 
- Run the following in your terminal
```
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
terraform init
terraform plan
terraform apply
```