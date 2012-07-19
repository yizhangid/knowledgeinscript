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


addipauser()
{
    local username=$1
    local firstname=$2
    local lastname=$3
    local userpw=$4
    echo -n "add user: [$username]"
    echo $userpw | ipa user-add $username --first=$firstname --last=$lastname --password 2>&1 >/dev/null
}

echo $pw |kinit admin 2>&1 >/dev/null
groupname=group$RANDOM
echo "create group: [$groupname]"
ipa group-add $groupname --desc "add group $groupname" 2>&1 >/dev/null
n=0
while [ $n -lt 3 ];do
    id=$RANDOM
    username="testuser$id"
    firstname="test$id"
    lastname="ipa$id"
    userpw="pw$id"
    addipauser $username $firstname $lastname $userpw
    n=$((n+1))
    echo " append to: [$groupname]"
    ipa group-add-member --users=$username $groupname 2>&1 >/dev/null
done

echo -n "[$groupname]" 
ipa group-show $groupname --all | grep "Member users"
kdestroy 2>&1 >/dev/null

