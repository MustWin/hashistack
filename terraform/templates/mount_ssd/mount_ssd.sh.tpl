#!/bin/bash
set -e

logger() {
  DT=$(date '+%Y/%m/%d %H:%M:%S')
  echo "$DT mount_ssd.sh: $1"
  echo "$DT mount_ssd.sh: $1" | sudo tee -a /var/log/user_data.log > /dev/null
}

logger "Begin script"

logger "Mount local SSD"
sudo mkdir -p ${mount_dir}
sudo mkfs.ext4 -F /dev/disk/by-id/${local_ssd_name}
sudo mount -o discard,defaults /dev/disk/by-id/${local_ssd_name} ${mount_dir}
sudo chmod a+w ${mount_dir}

logger "Optimize local SSD"
echo deadline | sudo tee -a /sys/block/sdb/queue/scheduler
echo 1 | sudo tee -a /sys/block/sdb/queue/iosched/fifo_batch
echo "tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0" | sudo tee -a /etc/fstab

if [ ! -f /home/ubuntu/c1m/reboot ]; then
  logger "Local SSD reboot"
  sudo reboot
  exit 0
fi

logger "Done"

exit 0
