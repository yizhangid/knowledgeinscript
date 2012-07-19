#!/bin/bash
# script : ipa.cert.create.request.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh


create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    local exp=/tmp/createCertRequestFile.$RANDOM.exp  # local test

    echo "set timeout 1" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .1}" >> $exp
    echo "spawn $certCmd" >> $exp
    echo 'match_max 100000' >> $exp

    echo 'expect "Country Name *"' >> $exp
    echo "send -s -- \"US\r\"" >> $exp

    echo 'expect "State or Province Name *"' >> $exp
    echo "send -s -- \"CA\r\"" >> $exp

    echo 'expect "Locality Name *"' >> $exp
    echo "send -s -- \"Mountain View\r\"" >> $exp

    echo 'expect "Organization Name *"' >> $exp
    echo "send -s -- \"IPA\r\"" >> $exp

    echo 'expect "Organizational Unit Name *"' >> $exp
    echo "send -s -- \"QA\r\"" >> $exp

    echo 'expect "Common Name *"' >> $exp
    echo "send -s -- \"$hostname\r\"" >> $exp

    echo 'expect "Email Address *"' >> $exp
    echo "send -s -- \"ipaqa@redhat.com\r\"" >> $exp

    echo 'expect "A challenge password *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect "An optional company name *"' >> $exp
    echo "send -s -- \"\r\"" >> $exp

    echo 'expect eof ' >> $exp
    
    echo "===== expect file is ready [$exp] ===="
    cat $exp
    /usr/bin/expect $exp

    echo "===request done, here is request file [$requestFile ]=="
    cat $requestFile
} #create_cert_request_file

hostname=$1
requestFile=$2
keyFile=$3
id=$RANDOM

echo "tool to create a cert request"
if [ "$hostname" = "" ];then
    hostname=`hostname`
fi
if [ "$requestFile" = "" ];then
    requestFile="./autocert.$id.request.csr"
    keyFile="./autocert.$id.private.key.txt"
    echo "no request file name given, use current directory, use random name"
    echo "request file: [$requestFile], private key file [$keyFile]"
fi
create_cert_request_file $requestFile $keyFile

echo "========== cert req file report ================="
echo "  host name        : [$hostname]"
echo "  request file     : [$requestFile] "
echo "  private key file : [$keyFile]"
echo "  to add cert into ipa , run command:"
echo "  ipa cert-request --principal=test$RANDOM/$hostname@YZHANG.REDHAT.COM --add $requestFile"
echo "================================================="
echo ""
