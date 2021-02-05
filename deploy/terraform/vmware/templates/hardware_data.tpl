{
  "id": "${id}",
  "metadata": {
    "facility": {
      "facility_code": "${facility_code}"
    },
    "instance": {},
    "state": ""
  },
  "network": {
    "interfaces": [
      {
        "dhcp": {
          "arch": "x86_64",
          "ip": {
            "address": "${address}",
            "gateway": "192.168.1.1",
            "netmask": "255.255.255.248"
          },
          "mac": "${mac}",
          "uefi": false
        },
        "netboot": {
          "allow_pxe": true,
          "allow_workflow": true
        }
      }
    ]
  }
}
