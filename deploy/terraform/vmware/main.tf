terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "1.24.3"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

locals {
  provisioner   = "tink-provisioner"

  cloud_init = templatefile("${path.module}/templates/cloud-init.tpl", {
    install_package_sh  = file("${path.module}/../../scripts/install_package.sh")
    ssh_authorized_keys = var.ssh_keys
  })
}

resource "vsphere_folder" "tink_folder" {
  count = var.folder != null ? 1 : 0

  path          = var.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}

resource "vsphere_virtual_machine" "tink_provisioner" {
  depends_on = [vsphere_folder.tink_folder]

  name = local.provisioner

  resource_pool_id = data.vsphere_compute_cluster.tink_compute_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.tink_datastore.id
  folder           = var.folder

  num_cpus = var.cpus_count
  memory   = var.memory
  guest_id = data.vsphere_virtual_machine.tink_provisioner_template.guest_id

  network_interface {
    network_id = data.vsphere_network.tink_network.id
  }

  network_interface {
    network_id = data.vsphere_network.tink_provisioning_network.id
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.tink_provisioner_template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.tink_provisioner_template.disks[0].thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.tink_provisioner_template.id
  }

  vapp {
    properties = {
      hostname  = local.provisioner
      user-data = base64encode(local.cloud_init)
    }
  }
}

resource "null_resource" "tink_directory" {
  connection {
    type = "ssh"
    user = var.ssh_user
    host = vsphere_virtual_machine.tink_provisioner.default_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p $HOME/tink/deploy"
    ]
  }

  provisioner "file" {
    source      = "../../../setup.sh"
    destination = "$HOME/tink/setup.sh"
  }

  provisioner "file" {
    source      = "../../../current_versions.sh"
    destination = "$HOME/tink/current_versions.sh"
  }

  provisioner "file" {
    source      = "../../../generate-envrc.sh"
    destination = "$HOME/tink/generate-envrc.sh"
  }

  provisioner "file" {
    source      = "../../../deploy"
    destination = "$HOME/tink"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iptables -A FORWARD -i ens224 -j ACCEPT",
      "sudo iptables -A FORWARD -i ens192 -j ACCEPT",
      "sudo iptables -t nat -A POSTROUTING -o ens192 -j MASQUERADE",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/tink/*.sh $HOME/tink/deploy/tls/*.sh"
    ]
  }
}

resource "vsphere_virtual_machine" "tink_worker" {
  count      = var.worker_count
  depends_on = [vsphere_folder.tink_folder]

  name = "tink-worker-${count.index}"

  resource_pool_id = data.vsphere_compute_cluster.tink_compute_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.tink_datastore.id
  folder           = var.folder

  num_cpus = var.worker_cpus_count
  memory   = var.worker_memory
  guest_id = data.vsphere_virtual_machine.tink_provisioner_template.guest_id

  wait_for_guest_ip_timeout   = 0
  wait_for_guest_net_routable = false
  wait_for_guest_net_timeout  = 0

  network_interface {
    network_id = data.vsphere_network.tink_provisioning_network.id
  }

  disk {
    label = "disk0"
    size  = var.worker_disk_size
  }
}

data "template_file" "worker_hardware_data" {
  count = var.worker_count

  template = file("${path.module}/templates/hardware_data.tpl")

  vars = {
    id            = vsphere_virtual_machine.tink_worker[count.index].id
    facility_code = "onprem"
    address       = "192.168.1.${count.index + 5}"
    mac           = vsphere_virtual_machine.tink_worker[count.index].network_interface.0.mac_address
  }
}

resource "null_resource" "hardware_data" {
  count      = var.worker_count
  depends_on = [null_resource.tink_directory]

  connection {
    type = "ssh"
    user = var.ssh_user
    host = vsphere_virtual_machine.tink_provisioner.default_ip_address
  }

  provisioner "file" {
    content     = data.template_file.worker_hardware_data[count.index].rendered
    destination = "$HOME/tink/deploy/hardware-data-${count.index}.json"
  }
}
