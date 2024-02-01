#!/bin/bash
set -e

# Install required packages (if not already installed)
sudo apt-get install -y expect

IP=$1

# Securely prompt for password
read -p "Enter your Linux password: " -s PASSWORD

cd support_files/4.3/File_System

echo "Sending runasroot"
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn scp -P 22 -o StrictHostKeyChecking=no runasroot root@$IP:/usr/bin
expect "root@$IP's password:"
send "$PASSWORD\r"
expect eof
EOF

echo "Sending Boot..."
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn scp -P 22 -o StrictHostKeyChecking=no boot.sh root@$IP:/
expect "root@$IP's password:"
send "$PASSWORD\r"
expect eof
EOF

cd ../App

echo "Sending App..."
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn scp -P 22 -o StrictHostKeyChecking=no -r 4tify.app root@$IP:/Applications
expect "root@$IP's password:"
send "$PASSWORD\r"
expect eof
EOF

echo "Moving Everything Into Place..."
sleep 2
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
expect "root@$IP's password:"
send "$PASSWORD\r"
expect "#"
send "chmod 6755 /Applications/4tify.app/4tify\r"
expect "#"
send "chmod 4755 /usr/bin/runasroot\r"
expect "#"
send "chown root:wheel /usr/bin/runasroot\r"
expect "#"
send "chmod 6755 /usr/bin/runasroot\r"
expect "#"
send "chmod 6755 /boot.sh\r"
expect "#"
send "exit\r"
expect eof
EOF

sleep 2
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 mobile@$IP
expect "mobile@$IP's password:"
send "$PASSWORD\r"
expect "mobile"
send "uicache\r"
expect "mobile"
send "exit\r"
expect eof
EOF

sleep 2
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
expect "root@$IP's password:"
send "$PASSWORD\r"
expect "#"
send "killall -9 SpringBoard\r"
expect "#"
send "exit\r"
expect eof
EOF

echo "Done!"
