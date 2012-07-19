#!/bin/bash
# script : ipa.sys.status.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


######### libs ###########
rpmstatus()
{
    echo "[rpm installed]"
    for rpmname in ipa-server ipa-client
    do
        local name=`rpm -qa | grep $rpmname | grep -v "selinux" | xargs echo`
        if [ "$name" = "" ];then
            echo "* $rpmname: NOT installed"
        else
            echo "* $rpmname: $name"
            local rpmpkg=`echo $name | cut -d"-" -f1,2`
        #   rpm -qi $rpmpkg | grep "Build Date"
        fi
    done
    echo ""
}

ipaserverstatus()
{
    local status=`which ipactl 2>&1`
    if echo $status | grep "no ipactl" 2>&1 >/dev/null
    then
        return
    else
        echo "[ipa server running status]"
        sudo ipactl status
        echo ""
    fi
}

ipaclientstatus()
{
    echo "[ipa client]"
    local conffile="/etc/ipa/default.conf"
    if [ -f $conffile ];then
        echo "* ipa client already configurated          "
    else
        echo "* no ipa client configurate file found     "
    fi
    echo ""
}

ipauserstatus()
{
    if echo $pw | kinit admin 2>&1 >/dev/null
    then
        totaluser=`ipa user-find | grep "[user|users] matched" | cut -d" " -f1`
        if [ "$totaluser" = "" ];then
            totaluser=0
        fi
        echo -n "total users : $totaluser"
        userlist=`ipa user-find | grep "User login" | xargs echo | sed "s/User login://g"`
        echo -e "\t[$userlist]"
    else
        echo "ipa server not connected or password [$pw] is wrong"
        return
    fi
}

ipagroupstatus()
{
    if echo $pw | kinit admin 2>&1 >/dev/null
    then
        totalgroup=`ipa group-find | grep "[group|groups] matched" | cut -d" " -f1`
        echo -n "total groups: $totalgroup"
        grouplist=`ipa group-find | grep "Group name" | xargs echo | sed  "s/Group name://g"`
        echo -e "\t[$grouplist]" 
    else
        echo "ipa server not connected or password [$pw] is wrong"
        return
    fi
}

ipahoststatus()
{
    if echo $pw | kinit admin 2>&1 >/dev/null
    then
        totalhost=`ipa host-find | grep "[host|hosts] matched" | cut -d" " -f1`
        echo -n "total hosts : $totalhost"
        hostlist=`ipa host-find | grep "Host name" | xargs echo | sed  "s/Host name://g"`
        echo -e "\t[$hostlist]" 
    else
        echo "ipa server not connected or password [$pw] is wrong"
        return
    fi
}
######### main #########
rpmstatus
ipaserverstatus
ipaclientstatus
echo "[ipa server entry]"
ipauserstatus
ipagroupstatus
ipahoststatus
echo ""
###################
# end of file     #
###################
