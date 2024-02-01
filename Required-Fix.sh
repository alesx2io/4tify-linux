#!/bin/bash
set -e

# Install required packages (if not already installed)
sudo apt-get install -y expect libimobiledevice6 libusbmuxd6

# Securely prompt for password
read -p "Enter your Linux password: " -s PASSWORD

# Check for required files
for file in ipwndfu irecovery irecovery2 tcprelay.py tar dd panguaxe.tar Cydia.tar APT.tar panguaxe-APT.tar panguaxe panguaxe.installed org.thebigboss.repo.icons_1.0.deb com.nyansatan.dualbootstuff_1.0.7a.deb cydia_1.1.9_iphoneos-arm.deb cydia-lproj_1.1.12_iphoneos-arm.deb openssl_0.9.8zg-13_iphoneos-arm.deb openssh_6.7p1-13_iphoneos-arm.deb coreutils_8.12-13_iphoneos-arm.deb bigbosshackertools_1.3.2-2.deb fstab; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found in the current directory."
        exit 1
    fi
done

cd support_files/7.1.2/Ramdisk
./ipwndfu -p
echo "Sending iBSS and iBEC"
./irecovery -f iBSS.n90ap.RELEASE.dfu
./irecovery -f iBEC.n90ap.RELEASE.dfu

# ... (rest of the script remains the same, but use sudo for commands requiring elevated privileges and provide password using echo "$PASSWORD" | sudo -S)
