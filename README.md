# Cloud Armor Demo

## Pre-Requisites
- Google Cloud Account 
- Billing Account
- Google Cloud Project with appropriate access to configure all the resources (For ex `Editor`)

## Installations
- gcloud SDK
- Terraform v1.x or higher

## Steps
- In your terminal, run `gcloud auth application-default login`
- Run `gcloud init` and set the gcloud config to your GCP project
- Make sure the Org policy for `constraints/compute.vmExternalIpAccess` is set to ALLOW 
- Run the following in your terminal
```
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
terraform init
terraform plan -var "project_id=$PROJECT_ID"
terraform apply -var "project_id=$PROJECT_ID"
```