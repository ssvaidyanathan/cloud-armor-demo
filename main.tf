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

 provider "google" {
  project     = "${var.project_id}"
}

resource "google_compute_network" "vpc_network" {
  delete_default_routes_on_create = true
  name                            = var.network
  auto_create_subnetworks         = false
  mtu                             = 1460
}

resource "google_compute_subnetwork" "subnet" {
  count         = length(var.exposure_subnets)
  name          = var.exposure_subnets[count.index].name
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.exposure_subnets[count.index].ip_cidr_range
  region        = var.exposure_subnets[count.index].region
}

resource "google_compute_firewall" "allow-ssh-in" {
  name      = "allow-ssh-in"
  network   = google_compute_network.vpc_network.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloudarmor-allow-http" {
  name      = "cloudarmor-allow-http"
  network   = google_compute_network.vpc_network.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "cloudarmor-allow-https" {
  name      = "cloudarmor-allow-https"
  network   = google_compute_network.vpc_network.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}