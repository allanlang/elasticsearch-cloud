resource "google_compute_network" "esnet" {
    name = "esnet"
}

resource "google_compute_subnetwork" "public" {
    name = "public"
    ip_cidr_range = "10.0.0.0/24"
    network = "${google_compute_network.esnet.self_link}"
    region = "europe-west1"
}

resource "google_compute_subnetwork" "private" {
    name = "private"
    ip_cidr_range = "10.0.10.0/24"
    network = "${google_compute_network.esnet.self_link}"
    region = "europe-west1"
}

resource "google_compute_firewall" "fw-internal-ssh" {
    name = "private-ssh"
    network = "${google_compute_network.esnet.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_tags = ["bastion-host"]
}

resource "google_compute_firewall" "fw-bastion-ssh" {
    name = "bastion-ssh"
    network = "${google_compute_network.esnet.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]

    target_tags = ["bastion-host"]
}

resource "google_compute_firewall" "fw-nat-tcp" {
    name = "nat-internal"
    network = "${google_compute_network.esnet.name}"

    allow {
        protocol = "tcp"
    }

    source_tags = ["no-ip"]

    target_tags = ["nat"]
}

resource "google_compute_route" "noip-internet-route" {
    name = "noip-internet-route"
    dest_range = "0.0.0.0/0"
    network = "${google_compute_network.esnet.name}"
    next_hop_instance = "${google_compute_instance.nat.name}"
    next_hop_instance_zone = "${google_compute_instance.nat.zone}"
    priority = 800
    tags = ["no-ip"]
}

resource "google_compute_firewall" "fw-es-api" {
    name = "es-api"
    network = "${google_compute_network.esnet.name}"

    allow {
        protocol = "tcp"
        ports = ["9200"]
    }

    source_tags = ["bastion-host", "es-node"]

    target_tags = ["es-node"]

}

resource "google_compute_firewall" "fw-es-internode" {
    name = "es-internode"
    network = "${google_compute_network.esnet.name}"

    allow {
        protocol = "tcp"
        ports = ["9300"]
    }

    source_tags = ["es-node"]

    target_tags = ["es-node"]

}
