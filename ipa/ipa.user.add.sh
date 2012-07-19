#!/bin/bash
# script : ipa.user.add.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

username="testuser$RANDOM"
firstname="test$RANDOM"
lastname="ipa$RANDOM"
userpw="pw$RANDOM"

echo "add a random ipa test user account"
echo "command used:"
echo "echo $userpw | ipa user-add $username --first=$firstname --last=$lastname --password 2>&1 >/dev/null"
echo ""
echo $pw |kinit admin 2>&1 >/dev/null
echo $userpw | ipa user-add $username --first=$firstname --last=$lastname --password 2>&1 >/dev/null

ipa user-find $username --all --raw
kdestroy 2>&1 >/dev/null

echo "ipa user [$username] password [$userpw]"
echo "to delete: [ ipa user-del $username ]"
