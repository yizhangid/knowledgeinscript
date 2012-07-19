#!/bin/bash
# script : ipa.group.list.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

echo $pw | kinit admin 2>&1 > /dev/null
groups=`ipa group-find | grep "Group name:" | cut -d":" -f2 | sort | xargs echo`
echo "ipa groups:"
echo "----------"
echo  $groups
echo ""
