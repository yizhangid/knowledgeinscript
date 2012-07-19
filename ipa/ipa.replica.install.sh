#!/bin/bash
# script : ipa.replica.install.sh
# date   : 2012.07.19
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

#########################
replica_hostname=$1
replica_ip=$2

echo "setp 1. prepare replica [on ipa master server]"
ipa-replica-preapre  $replica_hostname --ip-address $replica_ip

echo "step 2. copy prepare file to replica"
replica_preparefile="$replica_preparefile_dir/replica-info-${replica_hostname}.gpg"
scp $replica_preparefile root@${replica_hostname}:$replica_preparefile

echo "step 3. set up replica"
ssh root@$replica_hostname "ipa-replica-install --setup-ca --setup-dns $replica_preparefile"

echo "step 4. done"
