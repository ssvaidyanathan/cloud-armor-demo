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

project_id = "change_this"
network    = "cloudarmor-lab"
exposure_subnets = [
  {
    name               = "backend-us-west1"
    ip_cidr_range      = "10.10.0.0/16"
    region             = "us-west1"
    secondary_ip_range = null
  },
  {
    name               = "client-us-west1"
    ip_cidr_range      = "10.20.0.0/16"
    region             = "us-west1"
    secondary_ip_range = null
  },
  {
    name               = "client-europe-west1"
    ip_cidr_range      = "10.30.0.0/16"
    region             = "europe-west1"
    secondary_ip_range = null
  }
]
client_vms = [
  {
    name         = "client-eu"
    machine_type = "e2-micro"
    zone         = "europe-west1-b"
    subnetwork   = "client-europe-west1"
  },
  {
    name         = "client-us"
    machine_type = "e2-micro"
    zone         = "us-west1-b"
    subnetwork   = "client-us-west1"
  }
]
backend_vms = [
  {
    name           = "red"
    machine_type   = "e2-micro"
    zone           = "us-west1-b"
    tags           = ["http-server"]
    subnetwork     = "backend-us-west1"
    startup_script = "./startup_scripts/red.sh"
  },
  {
    name           = "blue"
    machine_type   = "e2-micro"
    zone           = "us-west1-b"
    tags           = ["http-server"]
    subnetwork     = "backend-us-west1"
    startup_script = "./startup_scripts/blue.sh"
  }
]