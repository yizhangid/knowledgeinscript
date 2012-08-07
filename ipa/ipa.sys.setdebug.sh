#!/bin/bash
# script : ipa.sys.debug.set.sh
# date   : 2012.08.07
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

usage()
{
    echo "Usage: $0 on/off"
}

if [ ! -w $ipa_conf ];then
    echo "ipa conf file :[$ipa_conf] is not writable, exit"
    exit 1
fi

status=$1

ipaconf_bk=/tmp/ipa.conf.$RANDOM.bk
cp $ipa_conf $ipaconf_bk
echo "#[`date`] auto back up by $0 " >> $ipaconf_bk

if [ "$status" = "on" ]
then
    echo "set ipa debug to 'on'"
    if grep -i "^debug=true" $ipa_conf 2>&1 > /dev/null
    then
        echo -n "ipa debug already set to on, do you want to restart to load it (n/y)? "
        read restart
        if [ "$restart" = "y" ];then
            service httpd restart
            echo "service restarted"
        fi
    else
        if grep -i "^#debug=true" $ipa_conf 2>&1 /dev/null
        then
            sed -e "s/#debug=true/debug=true/g" $ipaconf_bk > $ipa_conf
        else
            echo "debug=true" >> $ipa_conf
        fi
        echo "done file changing, now restart ipa to make it take effect"
        service httpd restart
        echo "service restarted, the ipa conf file has been backed up as [$ipaconf_bk]"
    fi
elif [ "$status" = "off" ]
then
    echo "set ipa debug to 'off'"
    if grep -i "^debug=true" $ipa_conf 2>&1 > /dev/null
    then
        echo "current setting is on, change it to off"
        sed -e "s/debug=true/#debug=true/g" $ipaconf_bk > $ipa_conf
        echo "file change done, now restart httpd"
        service httpd restart
        echo "service restarted, the ipa conf file has been backed up as [$ipaconf_bk]"
    else
        echo -n "ipa debug already set to off, do you want to restart to load it (n/y) "
        read restart
        if [ "$restart" = "y" ];then
            service httpd restart
            echo "service restarted"
        fi
    fi
else
    usage
fi

