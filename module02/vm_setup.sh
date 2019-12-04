#!/bin/bash -
vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH

vbmg createvm --name VM_ACIT4640 --ostype "Linux, Red Hat (64-bit)" --register

VM_NAME="VM_ACIT4640"
SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")

echo "${VM_DIR}/test.vdi"

vbmg createmedium disk --filename "${VM_DIR}/test.vdi" --size 10000 --format VDI 

vbmg storagectl VM_ACIT4640 --name "SATA Controller" --add SATA
vbmg storageattach VM_ACIT4640 --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_DIR}/test.vdi"
vbmg storagectl VM_ACIT4640 --name "IDE Controller" --add IDE
vbmg storageattach VM_ACIT4640 --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "${VBOX_FILE}/test.iso"

vbmg modifyvm VM_ACIT4640 --memory 1000 --cpus 1 --nic1 natnetwork --nat-network1 net_4640_1 --audio none 

