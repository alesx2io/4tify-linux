#!/bin/bash
set -e
cd support_files/7.1.2/Jailbreak

# Establish SSH connection to the device
ssh -o StrictHostKeyChecking=no -p 2022 root@localhost

# Mount device filesystems
mkdir -p /mnt1
mkdir -p /mnt1/private/var
mount -t hfs /dev/disk0s1 /mnt1
mount -t hfs /dev/disk0s2s1 /mnt1/private/var

# Install Expect for SSH interaction
apt-get install pexpect

# Send jailbreak files
pexpect << EOF
spawn scp -P 2022 tar dd root@localhost:/bin
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof

spawn scp -P 2022 panguaxe.tar root@localhost:/mnt1/private/var
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof

spawn scp -P 2022 Cydia.tar root@localhost:/mnt1/private/var
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof

spawn scp -P 2022 APT.tar root@localhost:/mnt1/private/var
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof

spawn scp -P 2022 panguaxe-APT.tar root@localhost:/mnt1/private/var
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof

spawn scp -P 2022 panguaxe root@localhost:/mnt1/private/var
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect eof
EOF

# Perform jailbreaking
pexpect << EOF
spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
log_user 0
expect "root@localhost's password:"
send "alpine\r"
expect "sh-4.0#"

# Unpack jailbreak files
send "tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe.tar -C /mnt1\r"
expect "sh-4.0#"

send "tar -x --no-overwrite-dir -f /mnt1/private/var/Cydia.tar -C /mnt1\r"
expect "sh-4.0#"

send "tar -x --no-overwrite-dir -f /mnt1/private/var/APT.tar -C /mnt1\r"
expect "sh-4.0#"

send "tar -x --no-overwrite-dir -f /mnt1/private/var/panguaxe-APT.tar -C /mnt1\r"
expect "sh-4.0#"

# Remove original jailbreak files
send "rm -rf /mnt1/panguaxe\r"
expect "sh-4.0#"

# Copy extracted jailbreak files
send "cp -a /mnt1/private/var/panguaxe /mnt1\r"
expect "sh-4.0#"

# Create directory for Cydia's auto-install files
send "mkdir -p /mnt1/private/var/root/Media/Cydia/AutoInstall\r"
expect "sh-4.0#"

# Exit
send "exit\r"
expect eof
EOF

# Send deb files
pexpect << EOF
spawn scp -P 2022 org.thebigboss.repo.icons_1.0.deb root@localhost:/mnt1/private/var/root/
