
# Define the region, zone and project where activities will happen
provider "google" {
  project = ""
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_disk" "balanced" {
    name  = "balanced"
    type  = "pd-ssd"
    zone  = "us-central1-c"
    image = data.google_compute_image.debian.self_link    
    #snapshot = "blog-2017-02-08"
    size = 10
}

# Create the vm along with the initial boot volume above
resource "google_compute_instance" "s4_hana" {
  name         = "instance-1"
  machine_type = "e2-medium"
  zone         = "us-central1-c"

  network_interface {
    network = "default"
  }

  boot_disk {
    #initialize_params {
    #  image = data.google_compute_image.debian.self_link
    #   source = google_compute_disk.balanced.self_link
    #}
    source = google_compute_disk.balanced.name    
  }
  
}

# Take a snapshot of the boot volume referencing the boot volume of the vm, this is dependent on the vm/boot disk being created
resource "google_compute_snapshot" "s4_hana_snapshot" {
  name        = "s4-hana-snapshot"
  source_disk = google_compute_disk.balanced.name
  zone        = "us-central1-c"
  labels = {
    my_label = "balanced_to_extreme"
  }
  storage_locations = ["us-central1"]
  timeouts {
    create = "60m"
  }
  depends_on = [
    google_compute_instance.s4_hana,
  ]
}

# Data to retrieve image for boot vol
data "google_compute_image" "debian" {
  family  = "debian-9"
  project = "debian-cloud"
}

# Create a new disk volume(extreme pd) using 
resource "google_compute_disk" "extreme_pd" {
  name  = "extreme-disk"
  type  = "pd-extreme"
  zone  = "us-central1-c"
  #image = data.google_compute_image.debian.self_link
  snapshot = google_compute_snapshot.s4_hana_snapshot.name
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}


resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.extreme_pd.id
  instance = google_compute_instance.s4_hana.id
}

