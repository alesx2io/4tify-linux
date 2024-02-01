#!/bin/bash
set -e

# Install required packages (if not already installed)
sudo apt-get install -y expect

ps -fA | grep 2022 | grep -v grep | awk '{print <span class="math-inline">2\}' \| sudo <0\>xargs kill
cd support\_files/4\.3/File\_System
srcdirs\=</span>(find . -name '*TwistedMind2-*')
cd ../../7.1.2/Ramdisk

echo "Please Put Your Device Into DFU Mode"
while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (DFU Mode)" 2> /dev/null); do
  sleep 1
done

./ipwndfu -p
echo "Sending iBSS and iBEC"
./irecovery -f iBSS.n90ap.RELEASE.dfu
./irecovery -f iBEC.n90ap.RELEASE.dfu

echo "Waiting for Connection, This Might Take Some Time..."
while !(system_profiler SPUSBDataType 2> /dev/null | grep "Apple Mobile Device (Recovery Mode)" 2> /dev/null); do
  sleep 1
done

n=0
until [ <span class="math-inline">n \-ge 5 \]
do</0\>
sudo /<0\>usr/bin/expect <\(cat << EOF
set timeout \-1
log\_user 0
spawn \-noecho \./irecovery2 \-s
expect "iRecovery\>"
send "/send devicetree\\r"
expect "iRecovery\>"
send "DeviceTree\.n90ap\.img3\\r"
expect "iRecovery\>"
send "/send 058\-1056\-002\.dmg\\r"
expect "iRecovery\>"
send "ramdisk\\r"
expect "iRecovery\>"
send "/send kernelcache\.release\.n90\\r"
expect "iRecovery\>"
send "bootx\\r"
expect "iRecovery\>"
send "/exit\\r"
expect eof</0\>
<0\>EOF\) && break
n\=</span>((n+1))
  echo "Retrying iRecovery (This Might Take A Few Tries)"
  sleep 3
done

echo "Booting..."
sleep 2
while !(system_profiler SPUSBDataType 2> /dev/null | grep "iPhone" 2> /dev/null); do
  sleep 1
done

echo "Establishing Connection (5s)..."
sleep 5
sudo ./tcprelay.py > /dev/null 2>&1 -t 22:2022 &

cd ../../4.3/File_System
echo "Establishing Patching Environment (8s)..."
sleep 8

echo "Sending Patch..."
sleep 2
read -p "Enter your Linux password: " -s PASSWORD
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
  set timeout -1
  spawn scp -P 2022 -o StrictHostKeyChecking=no ${srcdirs:2} root@localhost:/
  expect "root@localhost's password:"
  send "$PASSWORD\r"
  expect eof
EOF

echo "Sending dd..."
sleep 2
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
  set timeout -1
  spawn scp -P 2022 -o StrictHostKeyChecking=no dd root@localhost:/bin
  expect "root@localhost's password:"
  send "$PASSWORD\r"
  expect eof
EOF

echo "Patching..."
sleep 2
echo "$PASSWORD" | sudo -S /usr/bin/expect << EOF
  set timeout -1
  spawn ssh -o StrictHostKeyChecking=no -p 2022 root@localhost
  expect "root@localhost's password:"
  send "<span class="math-inline">PASSWORD\\r"
expect "sh\-4\.0\#"
send "dd if\=</span>{srcdirs:1} of=/dev/rdisk0
