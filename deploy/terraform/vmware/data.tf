data "vsphere_datacenter" "tink_datacenter" {
  name = var.datacenter
}

data "vsphere_datastore" "tink_datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}

data "vsphere_compute_cluster" "tink_compute_cluster" {
  name          = var.compute_cluster
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}

data "vsphere_network" "tink_network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}

data "vsphere_network" "tink_provisioning_network" {
  name          = var.network_provisioning
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}

data "vsphere_virtual_machine" "tink_provisioner_template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.tink_datacenter.id
}
