#cloud-config
package_update: true
package_upgrade: true
ssh_authorized_keys:
  %{ for key in ssh_keys ~}
  - ${key}
  %{ endfor ~}
