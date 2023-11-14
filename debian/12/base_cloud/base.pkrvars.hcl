vm_name                   = "debian12_base_cloud"
iso_url                   = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
iso_checksum              = "file:https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS"
packer_ansible_host_alias = "debian12"
disk_image                = true

qemuargs = [
  ["-smp", "4"],
  ["-smbios", "type=1,serial=ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/12/base_cloud/cloud-init/"]
]

packer_ansible_groups = [
  "cloud-init-servers"
]