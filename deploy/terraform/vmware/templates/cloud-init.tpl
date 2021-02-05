#cloud-config

packages:
  - jq
  - ifupdown

%{~ if length(ssh_authorized_keys) != 0 ~}
ssh_authorized_keys:
  %{ for ssh_key in ssh_authorized_keys ~}
  - ${ssh_key}
  %{ endfor ~}
%{~ endif ~}

write_files:
  - content: ${base64encode(install_package_sh)}
    path: /root/install_package.sh
    encoding: base64
    permissions: '0755'

runcmd:
  - [ sh, -c, /root/install_package.sh ]

