#!/bin/bash

systemctl list-timers vm-backup*
systemctl is-enabled vm-backup.timer
systemctl start vm-backup
