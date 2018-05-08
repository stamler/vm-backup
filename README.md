# vm-backup
Backup live qemu-kvm VMs running on CentOS 7/RHEL via rsync

# Installation

```
sudo su -
cd ~
wget https://github.com/stamler/vm-backup/archive/master.zip -O temp.zip
unzip temp.zip && rm -rf temp.zip
cd ./vm-backup-master
chmod 700 ./*.sh
./install.sh
```

# Confirm Installation
```
./confirm.sh
```
