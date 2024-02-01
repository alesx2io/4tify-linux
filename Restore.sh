#!/bin/bash
set -e

# Install required packages (if not already installed)
sudo apt-get install -y libimobiledevice6 libusbmuxd6 sshtool idevicerestore

# Securely prompt for password
read -p "Enter your Linux password: " -s PASSWORD

IP=$1
cd support_restore/

# Use sudo for commands requiring elevated privileges and provide password securely
echo "$PASSWORD" | sudo -S ./sshtool -k kloader -b pwnediBSS -p 22 $IP &

while !(system_profiler SPUSBDataType 2> /dev/null | grep " Apple Mobile Device" 2> /dev/null); do
    sleep 1
done

set +e
echo "$PASSWORD" | sudo -S ./idevicerestore -e -y custom.ipsw
echo "Done!"
