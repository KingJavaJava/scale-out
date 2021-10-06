provider "google" {
  project = "rexorioko"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.extreme_pd.id
  instance = google_compute_instance.instance-1.id
}

resource "google_compute_disk" "extreme_pd" {
  name  = "extreme-disk"
  type  = "pd-ssd"
  zone  = "us-central1-c"
  image = "debian-9-stretch-v20200805"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 1073741824
}
