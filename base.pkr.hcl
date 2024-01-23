packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

// os specific variables
variable "user" {
  type    = string
  default = "vagrant"
}

variable "user_crypted_password" {
  type = string
  // mkpasswd -m sha-512 -S $(pwgen -ns 16 1) vagrant
  default   = "$6$5Ob7L9HkYiwjq1us$1wXwAIzX7emCRUMDCZZXzLUQVkPVtmkpl7hKtNxdHUO9WnTtFVCYsK1pBIQVuAfim7posesh.WqWK.jE2El66/"
  sensitive = true
}

variable "user_password" {
  type = string
  default   = "vagrant"
  sensitive = true
}

variable "user_ssh_public_key" {
  type = string
  # vagrant ssh key from https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
  default   = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
  sensitive = true
}

// qemu specific variables
variable "qemuargs" {
  type = list(list(string))
  default = [
    ["-smp", "2"]
  ]
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "disk_size" {
  type    = string
  default = "10G"
}

variable "disk_image" {
  type    = bool
  default = false
}

variable "headless" {
  type    = bool
  default = false
}

variable "vm_name" {
  type    = string
  default = "debian"
}

variable "debian_iso_key" {
  type    = string
  default = "debian11-netinst"
}

variable "boot_command_key" {
  type    = string
  default = "default"
}

variable "iso_url" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "isos" {
  type    = map(string)
  default = {}
}

variable "iso_checksums" {
  type    = map(string)
  default = {}
}

variable "output_root_path" {
  type    = string
  default = "./"
}

// ansible variables
variable "packer_ansible_playbook" {
  type    = string
  default = "base_playbook.yml"
}

variable "packer_ansible_playbook_dir" {
  type    = string
  default = "ansible"
}

// Used to import playbook from wrapper playbook run from packer_ansible_playbook_dir
variable "ansible_repository_playbook_dir" {
  type    = string
  default = "ansible"
}

variable "packer_ansible_playbook_command" {
  type    = string
  default = ""
}

variable "packer_ansible_use_proxy" {
  type    = bool
  default = true
}

variable "packer_ansible_keep_inventory_file" {
  type    = bool
  default = false
}

variable "packer_ansible_env_vars" {
  type    = list(string)
  default = []
}

variable "packer_ansible_extra_vars" {
  type    = list(string)
  default = []
}

variable "packer_ansible_tags" {
  type    = list(string)
  default = []
}

variable "packer_ansible_skip_tags" {
  type    = list(string)
  default = []
}

variable "packer_ansible_playbook_raw_arguments" {
  type    = list(string)
  default = [
    // https://github.com/hashicorp/packer-plugin-ansible/issues/110
    "--scp-extra-args",
    "'-O'",
    "-v"
  ]
}

variable "packer_ansible_groups" {
  type    = list(string)
  default = []
}

variable "packer_ansible_empty_groups" {
  type    = list(string)
  default = []
}

variable "packer_ansible_inventory_directory" {
  type    = string
  default = ""
}

variable "packer_ansible_host_alias" {
  type    = string
  default = "default"
}

locals {
  _ansible_playbook_extra_vars = flatten(
    setproduct(["--extra-vars"],
      concat(
        var.packer_ansible_extra_vars,
        [
          "packer_user=${var.user}",
          "packer_user_ssh_public_key='${var.user_ssh_public_key}'",
          "ansible_repository_playbook_dir=${var.ansible_repository_playbook_dir}"
        ]
      )
    )
  )
  _ansible_tags      = flatten(setproduct(["--tags"], var.packer_ansible_tags))
  _ansible_skip_tags = flatten(setproduct(["--skip-tags"], var.packer_ansible_skip_tags))
  packer_ansible_extra_arguments = concat(
    local._ansible_playbook_extra_vars,
    local._ansible_tags,
    local._ansible_skip_tags,
    var.packer_ansible_playbook_raw_arguments
  )
  http_dir         = "${path.root}"
  iso_url          = "${lookup(var.isos, var.debian_iso_key, "${var.iso_url}")}"
  iso_checksum     = "${lookup(var.iso_checksums, var.debian_iso_key, "${var.iso_checksum}")}"
  image_output_dir = "${var.output_root_path}output/${var.vm_name}"
  boot_commands = {
    "debian10_base" = [
      "<esc><wait>",
      "auto ",
      //  "preseed/interactive=true ",
      "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/10/base/preseed/preseed.cfg ",
      "passwd/user-fullname=${var.user} ",
      "passwd/username=${var.user} ",
      "passwd/user-password-crypted=${var.user_crypted_password} ",
      "PACKER_USER=${var.user}",
      "<wait><enter>"
    ]
    "debian11_base" = [
      "<esc><wait>",
      "auto ",
      //  "preseed/interactive=true ",
      "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/11/base/preseed/preseed.cfg ",
      "passwd/user-fullname=${var.user} ",
      "passwd/username=${var.user} ",
      "passwd/user-password-crypted=${var.user_crypted_password} ",
      "PACKER_USER=${var.user}",
      "<wait><enter>"
    ]
    "debian12_base" = [
      "<esc><wait>",
      "auto ",
      //  "preseed/interactive=true ",
      "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/12/base/preseed/preseed.cfg ",
      "passwd/user-fullname=${var.user} ",
      "passwd/username=${var.user} ",
      "passwd/user-password-crypted=${var.user_crypted_password} ",
      "PACKER_USER=${var.user}",
      "<wait><enter>"
    ]
  }
}

source "qemu" "qemu_source" {
  iso_url          = local.iso_url
  iso_checksum     = local.iso_checksum
  output_directory = local.image_output_dir
  http_directory   = local.http_dir
  vm_name          = "${var.vm_name}.qcow2"
  headless         = "${var.headless}"
  shutdown_command = "echo ${var.user} | sudo -S shutdown -P now"
  memory           = var.memory
  // skip_resize_disk = true
  qemuargs       = var.qemuargs
  disk_size      = var.disk_size
  disk_image     = var.disk_image
  format         = "qcow2"
  accelerator    = "kvm"
  ssh_username   = var.user
  ssh_password   = var.user_password
  ssh_timeout    = "20m"
  net_device     = "virtio-net"
  disk_interface = "virtio"
  boot_wait      = "10s"
  boot_command   = "${lookup(local.boot_commands, var.boot_command_key, [""])}"
}

build {
  sources = [
    "source.qemu.qemu_source"
  ]

  provisioner "ansible" {
    playbook_file       = "${var.packer_ansible_playbook_dir}/${var.packer_ansible_playbook}"
    user                = var.user
    command             = var.packer_ansible_playbook_command
    use_proxy           = var.packer_ansible_use_proxy
    keep_inventory_file = var.packer_ansible_keep_inventory_file
    ansible_env_vars    = var.packer_ansible_env_vars
    groups              = var.packer_ansible_groups
    empty_groups        = var.packer_ansible_empty_groups
    inventory_directory = var.packer_ansible_inventory_directory
    host_alias          = var.packer_ansible_host_alias
    extra_arguments     = local.packer_ansible_extra_arguments
  }

  post-processor "checksum" {                  # checksum image
    checksum_types      = ["sha256", "sha512"] # checksum the artifact
    keep_input_artifact = true                 # keep the artifact
    output              = "${local.image_output_dir}/packer_{{.BuildName}}_{{.ChecksumType}}.checksum"
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      output              = "${local.image_output_dir}/${var.vm_name}_{{.BuildName}}_{{.Provider}}_{{.Architecture}}.box"
    }

    post-processor "checksum" {                  # checksum image
      checksum_types      = ["sha256", "sha512"] # checksum the artifact
      keep_input_artifact = true                 # keep the artifact
      output              = "${local.image_output_dir}/packer_{{.BuildName}}_{{.ChecksumType}}.checksum"
    }
  }

}

