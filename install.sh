#!/bin/bash

cp ~/vm-backup-master/vm-backup.sh /var/lib/libvirt/images/ &&
cp ~/vm-backup-master/vm-backup.service /usr/lib/systemd/system/vm-backup.service &&
cp ~/vm-backup-master/vm-backup.timer /usr/lib/systemd/system/vm-backup.timer &&
rm -rf ~/vm-backup-master
systemctl enable vm-backup.timer &&
systemctl start vm-backup.timer
