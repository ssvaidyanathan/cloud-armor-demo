# Cloud Armor Demo

## Pre-Requisites
- Google Cloud Account 
- Billing Account
- Google Cloud Project with appropriate access to configure all the resources (For ex `Editor`)
- The following org policies need to be updated if they are set:
    - `constraints/compute.vmExternalIpAccess` to ALLOW
    - `constraints/compute.requireShieldedVm` to false

NOTE: You will need Org Admin role to update this if the inherited values are different

## Installations
- gcloud SDK
- Terraform v1.x or higher
- cURL

## Steps
- In your terminal, run `gcloud auth application-default login`
- Run `gcloud init` and set the gcloud config to your GCP project
- Run the following in your terminal
```
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
terraform init
terraform plan -var "project_id=$PROJECT_ID"
terraform apply -var "project_id=$PROJECT_ID"
```
- Once the setup is complete, you will see few cURL commands to execute
- The setup is complete when the cURL commands give a valid response

### To destroy all resources
```
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
terraform init
terraform destroy -var "project_id=$PROJECT_ID"
```