#!/bin/bash

# script : ipa.client.install.sh
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

server=$1
if [ "$server" = "" ]
then
    echo -n "ipa server? "
    read server
    if [ "$server" = "" ];then
        echo "ipa server not given, exit";
        exit
    else
        echo "config client [$hostname] connect to server: [$server]"
    fi
fi
cmd="ipa-client-install --domain=$domain --server=$server --unattended --principal=admin --password=$pw --hostname=$hostname --mkhomedir -d"
force_cmd="ipa-client-install --domain=$domain --server=$server --unattended --principal=admin --password=$pw --hostname=$hostname  --force"
$cmd
ret=$?
echo "return code $ret"
if [ "$ret" = "1" ];then
    $force_cmd
fi

echo "cmd=$cmd"
echo "forcecmd=$force_cmd"
echo ""
