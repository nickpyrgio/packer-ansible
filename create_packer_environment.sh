#!/usr/bin/env bash

PACKER_ENV_DIR="../packer-env"
PACKER_PROJECT_DIR_NAME="packer-ansible"
mkdir -p \
    ${PACKER_ENV_DIR}/debian/10/ \
    ${PACKER_ENV_DIR}/debian/11/ \
    ${PACKER_ENV_DIR}/debian/12 \
    ${PACKER_ENV_DIR}/packer-ansible \
    ${PACKER_ENV_DIR}/packer-ansible/roles \
    ${PACKER_ENV_DIR}/packer-inventory \
    ${PACKER_ENV_DIR}/packer-inventory/group_vars \
    ${PACKER_ENV_DIR}/packer-inventory/host_vars

cd ${PACKER_ENV_DIR}
PACKER_ENV_DIR=`pwd`
echo ${PACKER_ENV_DIR}

ln -sf ../${PACKER_PROJECT_DIR_NAME}/base.pkr.hcl .
if ! test -f ${PACKER_ENV_DIR}/custom.auto.pkrvars.hcl; then
  cp ../${PACKER_PROJECT_DIR_NAME}/custom.auto.pkrvars.hcl.dist custom.auto.pkrvars.hcl
fi

cd ${PACKER_ENV_DIR}/packer-ansible
ln -sf ../../${PACKER_PROJECT_DIR_NAME}/packer-ansible/base_playbook.yml .

cd ${PACKER_ENV_DIR}/debian/10
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/10/base .
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/10/base_cloud .

cd ${PACKER_ENV_DIR}/debian/11
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/11/base .
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/11/base_cloud .

cd ${PACKER_ENV_DIR}/debian/12
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/12/base .
ln -sf ../../../${PACKER_PROJECT_DIR_NAME}/debian/12/base_cloud .