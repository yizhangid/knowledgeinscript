#!/bin/bash

# script : ipa.client.uninstall.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


echo sudo ipa-client-install --uninstall --unattended
sudo ipa-client-install --uninstall --unattended
echo ""
