# vm-backup
Backup live qemu-kvm VMs running on CentOS 7/RHEL via rsync

# Installation

```
cp vm-backup.sh /var/lib/libvirt/images/
cp vm-backup.service /usr/lib/systemd/system/vm-backup.service
cp vm-backup.timer /usr/lib/systemd/system/vm-backup.timer
systemctl enable vm-backup.timer
systemctl start vm-backup.timer
```

# Test
```
systemctl list-timers vm-backup*
systemctl is-enabled vm-backup.timer
systemctl start vm-backup
```
