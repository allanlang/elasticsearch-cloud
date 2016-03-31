resource "google_compute_instance" "bastion" {
    name = "bastion-host"
    machine_type = "f1-micro"
    zone = "europe-west1-b"
    tags = ["bastion-host"]

    disk {
        image = "centos-7-v20160301"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.public.name}"
        access_config {
            // Ephemeral IP
        }
    }

    metadata {
        role = "bastion"
    }

}

resource "google_compute_instance" "nat" {
    name = "nat"
    machine_type = "f1-micro"
    zone = "europe-west1-b"
    tags = ["nat"]
    can_ip_forward = true

    metadata_startup_script = "${file("nat-startup.sh")}"

    metadata {
        role = "nat"
    }

    disk {
        image = "debian-7-wheezy-v20160301"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.public.name}"
        access_config {
            // Ephemeral IP
        }
    }

}

resource "google_compute_instance_template" "elasticsearch-node" {
    name = "elasticsearch-node"
    description = "Elasticsearch node instance template"
    instance_description = "Elasticsearch node"
    machine_type = "n1-standard-2"
    can_ip_forward = false

    tags = ["es-node", "no-ip"]

    disk {
        source_image = "centos-7-v20160301"
        auto_delete = true
        boot = true
    }

    metadata {
        startup-script = "${file("node-startup.sh")}"
        role = "es-node"
    }

    disk {
        disk_type = "local-ssd"
        type = "SCRATCH"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.private.name}"
    }

    scheduling {
        automatic_restart = false
        preemptible = true
    }
	
}

resource "google_compute_instance_group_manager" "node-group" {
    description = "Elasticsearch node instance group manager"
    name = "es-node-group"
    instance_template = "${google_compute_instance_template.elasticsearch-node.self_link}"
    update_strategy= "NONE"
    base_instance_name = "es-node"
    zone = "europe-west1-b"
    target_size = 2

    named_port {
        name = "es-api"
        port = 9200
    }

}
