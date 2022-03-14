/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list(any)
}

variable "network" {
  description = "The VPC network"
  type        = string
  default     = "cloudarmor-lab"
}

variable "exposure_subnets" {
  description = "Subnets for exposing the services"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
  }))
  default = []
}

variable "client_vms" {
  description = "GCE instances"
  type = list(object({
    name         = string
    machine_type = string
    zone         = string
    subnetwork   = string
  }))
  default = []
}

variable "backend_vms" {
  description = "GCE instances"
  type = list(object({
    name           = string
    machine_type   = string
    zone           = string
    tags           = list(string)
    subnetwork     = string
    startup_script = string
  }))
  default = []
}