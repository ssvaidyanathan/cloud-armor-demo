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
  project = var.project_id
}

resource "google_project_service" "gcp_services" {
  count   = length(var.gcp_service_list)
  project = var.project_id
  service = var.gcp_service_list[count.index]

  disable_dependent_services = true
}

resource "google_project_organization_policy" "vmExternalIpAccess" {
  project    = var.project_id
  constraint = "constraints/compute.vmExternalIpAccess"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_project_organization_policy" "requireShieldedVm" {
  project    = var.project_id
  constraint = "constraints/compute.requireShieldedVm"

  boolean_policy {
    enforced = false
  }
}

resource "google_compute_network" "vpc_network" {
  delete_default_routes_on_create = false
  name                            = var.network
  auto_create_subnetworks         = false
  mtu                             = 1460
  depends_on                      = [google_project_service.gcp_services]
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

resource "google_compute_instance" "client-eu" {
  name         = "client-eu"
  machine_type = "e2-micro"
  zone         = "europe-west1-b"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet[2].id
    access_config {
      // Ephemeral IP
    }
  }
  depends_on = [google_project_organization_policy.vmExternalIpAccess, google_project_organization_policy.requireShieldedVm]
}

resource "google_compute_instance" "client-us" {
  name         = "client-us"
  machine_type = "e2-micro"
  zone         = "us-west1-b"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet[1].id
    access_config {
      // Ephemeral IP
    }
  }
  depends_on = [google_project_organization_policy.vmExternalIpAccess, google_project_organization_policy.requireShieldedVm]
}

resource "google_compute_instance" "backend_vms" {
  count        = length(var.backend_vms)
  name         = var.backend_vms[count.index].name
  machine_type = var.backend_vms[count.index].machine_type
  zone         = var.backend_vms[count.index].zone
  tags         = var.backend_vms[count.index].tags
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet[0].id
    access_config {
      // Ephemeral IP
    }
  }
  metadata = {
    enable-oslogin = "true"
  }

  metadata_startup_script = file(var.backend_vms[count.index].startup_script)
  depends_on              = [google_project_organization_policy.vmExternalIpAccess, google_project_organization_policy.requireShieldedVm]
}

resource "google_compute_instance_group" "ig-red" {
  name = "ig-red"
  zone = "us-west1-b"
  instances = [
    google_compute_instance.backend_vms[0].id
  ]
  named_port {
    name = "http"
    port = "80"
  }
  depends_on = [google_project_organization_policy.vmExternalIpAccess, google_project_organization_policy.requireShieldedVm]
}

resource "google_compute_instance_group" "ig-blue" {
  name = "ig-blue"
  zone = "us-west1-b"
  instances = [
    google_compute_instance.backend_vms[1].id
  ]
  named_port {
    name = "http"
    port = "80"
  }
  depends_on = [google_project_organization_policy.vmExternalIpAccess, google_project_organization_policy.requireShieldedVm]
}

resource "google_compute_health_check" "tcp-health-check" {
  name = "tcp-health-check"

  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2


  tcp_health_check {
    port = 80
  }

  depends_on = [google_project_service.gcp_services]
}

resource "google_compute_backend_service" "backend-blue" {
  name          = "backend-blue"
  health_checks = [google_compute_health_check.tcp-health-check.id]
  backend {
    group           = google_compute_instance_group.ig-blue.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  log_config {
    enable      = true
    sample_rate = 0.6
  }
  protocol   = "HTTP"
  port_name  = "http"
  depends_on = [google_project_service.gcp_services]
}

resource "google_compute_backend_service" "backend-red" {
  name          = "backend-red"
  health_checks = [google_compute_health_check.tcp-health-check.id]
  backend {
    group           = google_compute_instance_group.ig-red.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
  log_config {
    enable      = true
    sample_rate = 0.6
  }
  protocol   = "HTTP"
  port_name  = "http"
  depends_on = [google_project_service.gcp_services]
}

resource "google_compute_url_map" "urlmap" {
  name            = "cloudarmor-http-lb"
  default_service = google_compute_backend_service.backend-red.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.backend-red.id

    path_rule {
      paths = [
        "/red/",
        "/red/*"
      ]
      service = google_compute_backend_service.backend-red.id
    }
    path_rule {
      paths = [
        "/blue/",
        "/blue/*"
      ]
      service = google_compute_backend_service.backend-blue.id
    }
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.urlmap.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}