#!/bin/sh
# script : ipa.group.del.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


echo $pw | kinit admin  2>&1 >/dev/null
tmp=/tmp/ipa.username.$RANDOM.list
ipa group-find | grep "Group name" | cut -d":" -f2 | grep -v "admins" | grep -v "ipausers" | grep -v "editors" | sort | uniq > $tmp
for ipagroup in `cat $tmp`;do
    ipa group-del "$ipagroup"
done
rm $tmp
kdestroy 2>&1 >/dev/null
