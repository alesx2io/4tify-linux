#!/bin/bash
set -e

# Kill any existing processes using port 2022 to avoid conflicts
ps aux | grep 2022 | awk '{print $2}' | xargs kill

# Change directory to the Ramdisk directory
cd support_files/7.1.2/Ramdisk

# Put the device in PwnDFU mode
./ipwndfu -p

# Send iBSS and iBEC files
./irecovery -f iBSS.n90ap.RELEASE.dfu
./irecovery -f iBEC.n90ap.RELEASE.dfu

# Wait for device to enter recovery mode
while ! system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (Recovery Mode)" 2> /dev/null; do
  sleep 1
done

# Enter recovery mode
irecovery -f exit

# Boot device to normal mode
sleep 2

# Wait for device to connect in normal mode
while ! system_profiler SPUSBDataType 2> /dev/null | grep "iPhone" 2> /dev/null; do
  sleep 1
done

# Establish connection
ssh -p 2022 root@localhost

# Mount filesystems
ssh -p 2022 root@localhost "mount_hfs /dev/disk0s1 /mnt1"
ssh -p 2022 root@localhost "mount_hfs /dev/disk0s2s1 /mnt1/private/var"

# Send tar and dd tools
scp -P 2022 tar /bin/
scp -P 2022 dd /bin/

# Send jailbreak files
scp -P 2022 panguaxe.tar /mnt1/private/var/
scp -P 2022 Cydia.tar /mnt1/private/var/
scp -P 2022 APT.tar /mnt1/private/var/
scp -P 2022 panguaxe-APT.tar /mnt1/private/var/
scp -P 2022 panguaxe /mnt1/private/var/

# Jailbreak
ssh -p 2022 root@localhost "cd /mnt1/private/var/; tar -x --no-overwrite-dir -f panguaxe.tar; tar -x --no-overwrite-dir -f Cydia.tar; tar -x --no-overwrite-dir -f APT.tar; tar -x --no-overwrite-dir -f panguaxe-APT.tar; rm -rf panguaxe; cp -a panguaxe .; touch panguaxe.installed; touch /mnt1/private/var/mobile/Media/panguaxe.installed; mkdir -p /mnt1/private/var/root/Media/Cydia/AutoInstall"

# Send debs
scp -P 2022 org.thebigboss.repo.icons_1.0.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 com.nyansatan.dualbootstuff_1.0.7a.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 cydia_1.1.9_iphoneos-arm.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 cydia-lproj_1.1.12_iphoneos-arm.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 openssl_0.9.8zg-13_iphoneos-arm.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 openssh_6.7p1-13_iphoneos-arm.deb /mnt1/private/var/root/Media/Cydia/AutoInstall
scp -P 2022 coreutils_8.12-13_iphoneos-
