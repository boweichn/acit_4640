#!/bin/bash

NET_NAME="net_4640"
VM_NAME="VM_ACIT4640"
PXE_NAME="PXE_4640"

vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@";}

clean_all () {
	vbmg natnetwork remove --netname "$NET_NAME"
	vbmg unregistervm "$VM_NAME" --delete
}

create_network () {
	vbmg natnetwork add --netname "$NET_NAME" \
		--network 192.168.250.0/24 \
		--dhcp off \
		--enable \
		--port-forward-4 "ssh:tcp:[]:50022:[192.168.250.10]:22" \
		--port-forward-4 "http:tcp:[]:50080:[192.168.250.10]:80" \
		--port-forward-4 "https:tcp:[]:50443:[192.168.250.10]:443" \
		--port-forward-4 "ssh2:tcp:[]:50222:[192.168.250.200]:22" 		
}

create_vm () {
	vbmg createvm --name "$VM_NAME" --ostype "RedHat_64" --register
	vbmg modifyvm "$VM_NAME" --memory 2048 --nic1 natnetwork \
		--cableconnected1 on \
		--nat-network1 "$NET_NAME" \
		--audio none \
		--boot1 disk \
		--boot2 net \
		--boot3 none

	SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
	VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
	VM_DIR=$(dirname "$VBOX_FILE")

	vbmg createmedium disk --filename "${VM_DIR}/test.vdi" \
		--size 10000 \
		--format VDI

	vbmg storagectl $VM_NAME --name "SATA Controller" --add SATA
	vbmg storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${VM_DIR}/test.vdi"
	vbmg storagectl $VM_NAME --name "IDE Controller" --add IDE
	#vbmg storageattach $VM_NAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "C:/Users/StephenCheng/VirtualBox VMs/test.iso"
}

setup_pxe() {
	vbmg modifyvm $PXE_NAME --nic1 natnetwork --nat-network1 $NET_NAME --cableconnected1 on
	vbmg startvm $PXE_NAME
	cp support/acit_admin_id_rsa ~/.ssh/acit_admin_id_rsa
	chmod 600 ~/.ssh/acit_admin_id_rsa

	while /bin/true; do
        ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 -o ConnectTimeout=2 -q admin@localhost exit
        if [ $? -ne 0 ]; then
                echo "PXE server is not up, sleeping..."
                sleep 2
        else	
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chown -R admin:admin /var/www/lighttpd
				scp -i ~/.ssh/acit_admin_id_rsa -P 50222 ks.cfg admin@localhost:/var/www/lighttpd
				scp -r -i ~/.ssh/acit_admin_id_rsa -P 50222 support admin@localhost:/var/www/lighttpd
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chown -R lighttpd:wheel /var/www/lighttpd
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chown -R admin:admin /var/www/lighttpd/support
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chmod 755 /var/www/lighttpd/support/nginx.conf
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chmod 755 /var/www/lighttpd/support/todoapp.service
				ssh -i ~/.ssh/acit_admin_id_rsa -p 50222 admin@localhost sudo chmod 755 /var/www/lighttpd/ks.cfg
				startup_empty_vm
                break
        fi
	done
}

startup_empty_vm() {
	vbmg startvm $VM_NAME
}

clean_all
create_network
create_vm
setup_pxe

