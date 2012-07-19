#!/bin/bash
# script : ipa.group.add.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


# global variables
hostname=`hostname`
domain=`hostname -d`
realm=`echo $domain | tr '[:lower:]' '[:upper:]'`
# uninstall ipa server
cmd="sudo ipa-server-install --uninstall -U"
echo "uninstall ipa server in unattented mode"
echo "command to execute:[$cmd]"
$cmd

echo "ipa has been cleaned, now run ipa-server-install"

cmd="sudo ipa-server-install --hostname=$hostname --domain=$domain --realm=$realm --ds-password=$pw --master-password=$pw --admin-password=$pw --unattended  --setup-dns --forwarder $forwarder "
$cmd

echo "----- ipa refreshed -----"
echo ""
