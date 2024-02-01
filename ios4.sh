#!/bin/bash
set -e

# Set the IP address of the target device
IP=$1

# Prepare the device
cd support_files/4.3/File_System
./pzb -g 038-0688-006.dmg https://secure-appldnld.apple.com/iPhone4/041-0330.20110311.Cswe3/iPhone3,1_4.3_8F190_Restore.ipsw
./dmg extract 038-0688-006.dmg decrypted.dmg -k 34904e749a8c5cfabecc6c3340816d85e7fc4de61c968ca93be621a9b9520d6466a1456a
./dmg build decrypted.dmg UDZO.dmg

# Execute the script on the device using SSH
ssh root@$IP << EOF

# Create the required filesystems
mkdir /mnt1 /mnt2

# Create the hfs filesystems
/sbin/newfs_hfs -s -v System -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s3
/sbin/newfs_hfs -s -v Data -J -b 8192 -n a=8192,c=8192,e=8192 /dev/disk0s4

# Mount the filesystems
mount_hfs /dev/disk0s4 /mnt2

# Copy the patched filesystem
cp /mnt2/UDZO.dmg /dev/disk0s3

# Unmount the filesystems
umount /mnt1
umount /mnt2

# Apply the patches to the filesystem
fsck_hfs -f /dev/disk0s3

# Create a temporary mount point for the device filesystem
mkdir /mnt1

# Mount the device filesystem
mount_hfs /dev/disk0s3 /mnt1

# Move the keybag to a safe place
cp -a /mnt1/private/var/* /mnt2/keybags

# Patch the fstab file
cp fstab /mnt1/etc/fstab

# Unmount the filesystems
umount /mnt1
umount /mnt2

# Apply the boot files
cp applelogo /
cp devicetree /
cp kernelcache /
cp ramdisk /
cp iBEC.img3 /
cp iBSS.patched /

# Apply the runasroot script
cp runasroot /usr/bin/

# Apply the boot script
cp boot.sh /

# Transfer 4tify.app to the Applications folder
cp -r 4tify.app /Applications

# Change ownership and permissions
chown root:wheel /usr/bin/runasroot
chmod 4755 /usr/bin/runasroot
chmod 6755 /usr/bin/runasroot
chmod 6755 /boot.sh

# Respring the device
killall -9 SpringBoard

EOF

echo "Done!"
