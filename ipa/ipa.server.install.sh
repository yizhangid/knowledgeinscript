#!/bin/bash
# script : ipa.server.install.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


hostname=`hostname`
domain=`hostname -d`
realm=`echo $domain | tr '[:lower:]' '[:upper:]'`

echo -n -e "update OS (y/n)?"
read os 
if [ "$os" = "y" ];then
    yum update -y
fi

echo "check ipa-server build"
ipabuild=`rpm -qa | grep ipa-server | xargs echo`
if [ "$ipabuild" = "" ]
then
    echo "no ipa build detected, do yum install -y ipa-server bind bind-dyndb-ldap"
    sudo yum install  -y ipa-server bind bind-dyndb-ldap expect vim subversion screen rpm-build dbus
else
    echo "install 'bind' and 'bind-dyndb-ldap'"
    sudo yum install -y bind bind-dyndb-ldap expect vim subversion screen rpm-build dbus 
fi

echo "now run ipa-server-install"

cmd="sudo ipa-server-install --hostname=$hostname --domain=$domain --realm=$realm --ds-password=$pw --master-password=$pw --admin-password=$pw --unattended  --setup-dns --forwarder $forwarder "

echo "======= ready to install ipa server ======"
echo "  hostname: $hostname"
echo "  domain  : $domain"
echo "  realm   : $realm"
echo "  admin pw: $pw"
echo "  dns     : yes"
echo "  forwarder: $forwarder"
echo $cmd
echo "========================================="
echo -n -e "continue (y/n)? "
read choice
if [ "$choice" = "y" ];then
    echo "got it, let's install ipa"
else
    echo "as your wish, ipa install stopped"
    exit
fi

$cmd
echo "----- finished ipa server install now, config firewall for ipa server ----"
echo "open the ports "

echo "setting ports for ipa server"
echo "  tcp ports: $tcpports"
sudo iptables -I INPUT 4 -m state --state NEW -p tcp -m multiport --dports $tcpports -j ACCEPT 
echo "  udp ports: $udpports"
sudo iptables -I INPUT 4 -m state --state NEW -p udp -m multiport --dports $udpports -j ACCEPT 
sudo iptables --list --line-number -n
echo "----ipa setup done ----"
echo ""

