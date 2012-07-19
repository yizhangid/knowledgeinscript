#!/bin/bash
# script : ipa.data.cleanup.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 0.9 
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

echo $pw | kinit admin  2>&1 >/dev/null

echo "remove users"
ipa user-find | grep -i "user login" | grep -v "admin" | cut -d":" -f2 | xargs ipa user-del 2>/dev/null

echo "remove groups"
ipa group-find | grep "Group name" | cut -d":" -f2 | grep -v "admins" | grep -v "ipausers" | grep -v "editors" | xargs ipa group-del  2>/dev/null

echo "remove netgroups"
ipa netgroup-find | grep "Netgroup name" | cut -d":" -f2 | xargs ipa netgroup-del 2>/dev/null

echo "remove HBAC rules"
 ipa hbacrule-find | grep "Rule name" | grep -v "allow_all" | cut -d":" -f2 | xargs ipa hbacrule-del

echo "remove SUDO rules"
ipa sudorule-find | grep "Rule name" | cut -d":" -f2 | xargs ipa sudorule-del

echo "remove selfservice permissions"
allPermissions=`ipa selfservice-find | grep "Self-service name" | grep -v "Self can write own password" | grep -v "User Self service" | cut -d":" -f2`
for permission in $allPermissions
do
	ipa selfservice-del "$permission"
done

echo "remove automount locations"
allAutomountLocations=`ipa automountlocation-find | grep "Location" | grep -v "default" | cut -d":" -f2`
for locations in $allAutomountLocations
do
	ipa automountlocation-del "$locations"
done

echo "cleanup data done."
