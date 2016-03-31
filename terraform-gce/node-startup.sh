#!/bin/bash
# ONLY if /var/lib/elasticsearch does not exist should we format and then mount this volume!!!
if [ ! -d /var/lib/elasticsearch ]
then
    mkdir /var/lib/elasticsearch
    mkfs.ext4 -F /dev/disk/by-id/google-local-ssd-0
    mount -o discard,defaults /dev/disk/by-id/google-local-ssd-0 /var/lib/elasticsearch
    echo '/dev/disk/by-id/google-local-ssd-0 /var/lib/elasticsearch ext4 defaults 1 1' >> /etc/fstab
fi
