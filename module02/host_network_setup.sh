#!/bin/bash -
vbmg () { VBoxManage.exe "$@"; }
export PATH=/mnt/c/Program\ Files/Oracle/VirtualBox:$PATH
vbmg natnetwork add --netname net_4640 --network 192.168.250.0/24 \
    --enable --port-forward-4 "SSH:tcp:[192.168.250.10]:50022:[192.168.250.10]:22" \
    --port-forward-4 "HTTPS:tcp:[192.168.250.10]:50443:[192.168.250.10]:443" \
    --port-forward-4 "HTTP:tcp:[192.168.250.10]:50080:[192.168.250.10]:80" \
    --dhcp off