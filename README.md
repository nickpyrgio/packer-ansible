```bash

# To create base images run

packer build \
    --force \
    -var-file "debian/12/base_cloud/base.pkrvars.hcl" \
    -var "packer_ansible_playbook_command=/home/nikos/.virtualenvs/modulus_p311_a216/bin/ansible-playbook" \
    .

packer build \
    --force \
    -var-file "debian/11/base_cloud/base.pkrvars.hcl" \
    -var "packer_ansible_playbook_command=/home/nikos/.virtualenvs/modulus_p311_a216/bin/ansible-playbook" \
    .

packer build \
    --force \
    -var-file "debian/10/base_cloud/base.pkrvars.hcl" \
    -var "packer_ansible_playbook_command=/home/nikos/.virtualenvs/modulus_p311_a216/bin/ansible-playbook" \
    .
```
