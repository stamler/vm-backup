# vm-backup
Backup live qemu-kvm VMs running on CentOS 7/RHEL via rsync

# Installation

1. `cp vm-backup.sh /var/lib/libvirt/images/`
2. `cp vm-backup.service /usr/lib/systemd/system/vm-backup.service`
3. `cp vm-backup.timer /usr/lib/systemd/system/vm-backup.timer`
4. `systemctl enable vm-backup.timer`
5. `systemctl start vm-backup.timer`

# Test
6. `systemctl list-timers vm-backup*`
7. `systemctl is-enabled vm-backup.timer`
8. `systemctl start vm-backup`
