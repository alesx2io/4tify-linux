#!/bin/bash
set -e

IP=$1

# Install required packages (if not already installed)
sudo apt-get install -y expect

cd support_files/4.3/File_System

# Securely prompt for password
read -p "Enter your Linux password: " -s PASSWORD

# Use sudo with password for privilege escalation
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn ssh -o StrictHostKeyChecking=no -p 22 root@$IP
expect "root@$IP's password:"
send "$PASSWORD\r"
expect "#"
send "TwistedMind2 -d1 3221225472 -s2 879124480 -d2 max\r"
expect "#"
send "exit\r"
expect eof
EOF

sleep 2
echo "Fetching Patch File"
srcdirs=$(echo "$PASSWORD" | sudo -S ssh -n -p 22 root@$IP "find / -name '*TwistedMind2-*'")
echo "$srcdirs"

echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
set timeout -1
spawn scp -P 22 -o StrictHostKeyChecking=no root@$IP:$srcdirs $(pwd)
expect "root@$IP's password:"
send "$PASSWORD\r"
expect eof
EOF

echo "Done!"
