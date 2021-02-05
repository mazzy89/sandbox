output "provisioner_ip" {
  value = vsphere_virtual_machine.tink_provisioner.default_ip_address
}

output "worker_mac_addr" {
  value = formatlist("%s", vsphere_virtual_machine.tink_worker[*].network_interface.0.mac_address)
}
