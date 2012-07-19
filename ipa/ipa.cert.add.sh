#!/bin/bash
# script : ipa.cert.add.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

# include global ipa environment file

dir=$( cd "$( dirname "$0" )" && pwd )
. $dir/ipa.env.sh

# test data used in ipa cert test
hostname=`hostname | xargs echo`
certList=/tmp/certlist.$RANDOM.txt

LKinitAsAdmin()
{
    echo $pw | kinit admin@SJC.REDHAT.COM 2>&1 >/dev/null
} #LKinitAsAdmin

Kcleanup()
{
    kdestroy 2>&1
} #Kcleanup

create_cert()
{
    local serviceName=testservice_$RANDOM
    local certRequestFile=/tmp/certreq.$RANDOM.csr
    local certPrivateKeyFile=/tmp/certprikey.$RANDOM.key
    local principal=$serviceName/$hostname
    echo "certreq    [$certRequestFile]"
    echo "privatekey [$certPrivateKeyFile]"
    echo "principal  [$principal]"

    LKinitAsAdmin
    echo step 1: create/add a host this should already done : use existing host $hostname

    echo step 2: add a test service add service: [$principal]
    ipa service-add $principal

    echo step 3: create a cert request
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    local ret=$?
    if [ "$ret" = "0" ];then
        echo "cert file creation success, continue"
    else
        echo "cert file creation failed, return fail"
        return 1
    fi

    echo step 4: process cert request
    ipa cert-request --principal=$principal $certRequestFile 

    Kcleanup
 
} #create_cert

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    #local exp=/tmp/createCertRequestFile.$RANDOM.exp # beaker test
    local exp=/tmp/createCertRequestFile.$RANDOM.exp  # local test

    echo "set timeout 5" > $exp
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
    
    echo "create cert request file [$requestFile]"
    /usr/bin/expect $exp
    local ret=$?
   
} #create_cert_request_file
  
delete_cert()
{
    LKinitAsAdmin
    for cert in `cat $certList`
    do
        echo "line:[$cert]"
        local cert_principal=`echo $cert | cut -d"=" -f1`
        local cert_id=`echo $cert | cut -d"=" -f2`
        echo "remove the service and revoke the cert [$cert_principal $cert_id"
        ipa service-del $cert_principal
    done
    Kcleanup
} #delete_cert

########### main ############

echo "start to create a cert request and process it with ipa"
create_cert
echo "done"
echo ""


