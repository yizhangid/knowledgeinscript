#!/bin/bash
# script : ipa.sys.firewall.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

echo "setting ports for ipa server"
echo "  tcp ports: $tcpports"
sudo iptables -I INPUT 4 -m state --state NEW -p tcp -m multiport --dports $tcpports -j ACCEPT 
echo "  udp ports: $udpports"
sudo iptables -I INPUT 4 -m state --state NEW -p udp -m multiport --dports $udpports -j ACCEPT 

echo ""
sudo iptables --list --line-number -n
