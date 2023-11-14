vm_name                   = "debian11_base_cloud"
iso_url                   = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
iso_checksum              = "file:https://cloud.debian.org/images/cloud/bullseye/latest/SHA512SUMS"
packer_ansible_host_alias = "debian11"
disk_image                = true

qemuargs = [
  ["-smp", "4"],
  ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/11/base_cloud/cloud-init/"]
]

packer_ansible_groups = [
  "cloud-init-servers"
]