variable "vsphere_user" {
  type        = string
  description = "The username for vSphere API operations."
}

variable "vsphere_password" {
  type        = string
  description = "The password for vSphere API operations. "
}

variable "vsphere_server" {
  type        = string
  description = "This is the vCenter server name for vSphere API operations."
}

variable "datacenter" {
  type        = string
  description = "The name of the VMware datacenter. This can be a name or path."
}

variable "datastore" {
  type        = string
  description = "The name of the VMware datastore. This can be a name or path."
}

variable "compute_cluster" {
  type        = string
  description = "The name of the VMware computer cluster used for the placement of the virtual machine."
}

variable "network" {
  type        = string
  description = "The name of the VMware network to connect the main interface of the provisioner. This can be a name or path."
}

variable "network_provisioning" {
  type        = string
  description = "The name of the VMware network to connect the secondary interface of the provisioner. This can be a name or path."
}

variable "template" {
  type        = string
  description = "The name of the VMware template used for the creation of the instance."
}

# Optional variables.
variable "ssh_keys" {
  type        = list(string)
  description = "List of SSH public keys for user `core`. Each element must be specified in a valid OpenSSH public key format, as defined in RFC 4253 Section 6.6, e.g. 'ssh-rsa AAAAB3N...'."
  default     = []
}

variable "folder" {
  description = "The path to the folder to put this virtual machine in, relative to the datacenter that the resource pool is in."
  default     = null
}

variable "cpus_count" {
  type        = number
  description = "The total number of virtual processor cores to assign to this virtual machine."
  default     = 4
}

variable "memory" {
  type        = number
  description = "The size of the virtual machine's memory, in MB."
  default     = 4096
}

variable "disk_size" {
  type        = number
  description = "The size of the virtual machine's disk, in GB."
  default     = 30
}

variable "ssh_user" {
  type        = string
  description = "The SSH user used to run the remote provisioner."
  default     = "ubuntu"
}

variable "worker_count" {
  description = "Number of Workers"
  type        = number
  default     = 1
}

variable "worker_cpus_count" {
  type        = number
  description = "The total number of virtual processor cores to assign to this virtual machine."
  default     = 2
}

variable "worker_memory" {
  type        = number
  description = "The size of the virtual machine's memory, in MB."
  default     = 4096
}

variable "worker_disk_size" {
  type        = number
  description = "The size of the virtual machine's disk, in GB."
  default     = 30
}