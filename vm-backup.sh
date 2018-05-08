#!/bin/bash

function backup_vm() {
  local startTime=$(date +%s%N)
  local DOMAIN="$1"
  local RSYNCDEST="$2"

  printf "\n%s ☐" "$DOMAIN"

  # Get the list of targets & corresponding image paths ignoring cdroms.
  local TARGETS=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '$2 !~ /cdrom/ {print $3}'`
  local IMAGES=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '$2 !~ /cdrom/ {print $4}'`

  # Create the snapshot. Fail if no guest agent since --quiesce is specified
  local DISKSPEC=""
  for t in $TARGETS; do
      local DISKSPEC="$DISKSPEC --diskspec $t,snapshot=external"
  done
  printf "\b✓, snapshot ☐"
  virsh snapshot-create-as --domain "$DOMAIN" --name backup --no-metadata \
  	--atomic --disk-only --quiesce $DISKSPEC > /dev/null

  if [ $? -ne 0 ]; then
      echo "Failed to create snapshot for $DOMAIN"
      exit 1
  fi

  # Dump the configuration information.
  printf "\b✓, dumpxml ☐"
  virsh dumpxml "$DOMAIN" > "$DOMAIN.xml"

  # Backup the disk images
  printf "\b✓ "
  for t in $IMAGES; do
      printf "\n▲ rsyncing $t\n"
      # --inplace is used to write to the existing file on the destination
      # This ensures that btrfs snapshots on the destination are efficient COW
      # rather than entirely new files
      # Note that this behaviour may change if the destination is local
      rsync -av --inplace -e ssh $t $RSYNCDEST --progress
      rsync -av --inplace -e ssh "$DOMAIN.xml" "$RSYNCDEST/XML/" --progress
  done

  # Get backup images before merge
  local BACKUPIMAGES=`virsh domblklist "$DOMAIN" --details | grep ^file | awk '$2 !~ /cdrom/ {print $4}'`

  # Merge changes back.
  for t in $TARGETS; do
      virsh blockcommit "$DOMAIN" "$t" --active --verbose --pivot
      if [ $? -ne 0 ]; then
          echo "Could not merge changes for disk $t of $DOMAIN. VM may be in invalid state."
          exit 1
      fi
  done


  # Cleanup left over backup images.
  for t in $BACKUPIMAGES; do
      printf "cleaning $t ☐"
      rm -f "$t"
      printf "\b✓ "
  done
  rm -f "$DOMAIN.xml"

  local endTime=$(date +%s%N)
  local elapsed=$((endTime - startTime))
  local minutes=$(( elapsed / 60000000000))
  local seconds=$(( elapsed / 1000000000 - $minutes * 60 ))
  printf "\nFinished backup in %02d:%02d\n" "$minutes" "$seconds"

}


#list all vms to iterate over
exec >> /var/lib/libvirt/images/vm-backup.log 2>&1
date +"%Y-%m-%d %R"
DOMAINS=`virsh list --name`
RSYNCDEST="$1"

if [[  -z $RSYNCDEST ]]; then
    echo "Usage: ./vm-backup <rsync-destination-string>"
    echo "  <rsync-destination-string> example:"
    echo "    \"rsync_user@10.10.10.5::vm/\""
    exit 1
fi

for d in $DOMAINS; do
  backup_vm $d $RSYNCDEST
done

echo "Complete. Exiting..."
