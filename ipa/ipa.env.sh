#!/bin/bash
# script : ipa.env.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#


# this is global data file that relate to all ipa scripts.

tcpports="53,80,443,389,636,88,464,9180,9443,9444,9445,9446,9701"
udpports="53,88,464,123"
replica_preparefile_dir="/var/lib/ipa"
sssd_conf="/etc/sssd/sssd.conf"
ipa_conf="/etc/ipa/default.conf"
krb5_conf="/etc/krb5.conf"
