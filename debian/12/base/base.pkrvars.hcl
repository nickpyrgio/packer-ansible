vm_name          = "debian12_base"
boot_command_key = "debian12_base"
// https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/
iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
// https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS
iso_checksum              = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
packer_ansible_host_alias = "debian12"