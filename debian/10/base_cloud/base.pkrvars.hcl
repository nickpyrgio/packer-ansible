vm_name                   = "debian10_base_cloud"
iso_url                   = "https://cloud.debian.org/images/cloud/buster/latest/debian-10-genericcloud-amd64.qcow2"
iso_checksum              = "file:https://cloud.debian.org/images/cloud/buster/latest/SHA512SUMS"
packer_ansible_host_alias = "debian10"
disk_image                = true

qemuargs = [
  ["-smp", "4"],
  ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/10/base_cloud/cloud-init/"]
]

packer_ansible_groups = [
  "cloud-init-servers"
]