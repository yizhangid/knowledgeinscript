#!/bin/sh
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

Local_KinitAsAdmin()
{
    #local pw=$adminpassword
    local pw=$pw #use the password in env.sh file
    local out=$tmpdir/kinitasadmin.$RANDOM.txt
    local exp
    local temppw
    echo "[Local_KinitAsAdmin] kinit with password: [$pw]"
    echo $pw | kinit admin 2>&1 > $out
    if [ $? = 0 ];then
        echo "[Local_KinitAsAdmin] kinit as admin with [$pw] success"
    elif [ $? = 1 ];then
        echo "[Local_KinitAsAdmin] kinit as admin with [$pw] failed"
        echo "[Local_KinitAsAdmin] check ipactl status"
        ipactl status
        if echo $pw | kinit admin | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[Local_KinitAsAdmin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            kdestroy
            echo $pw | kinit admin 2>&1 > $out
            if [ $? = 0 ];then
                echo "[Local_KinitAsAdmin] kinit as admin with [$pw] success at second attemp -- after restart ipa"
                return
            fi
        fi        
            
        echo "========================================="
        echo "[Local_KinitAsAdmin] password [$pw] failed, check whether it is because password expired"
        echo "============ output of [echo $pw | kinit $ADMIN] ============="
        cat $out
        echo "============================================================"
        if grep "Password expired" $out 2>&1 >/dev/null
        then
            echo "admin password exipred, do reset process"
            exp=$tmpdir/resetadminpassword.$RANDOM.exp
            temppw="New_$pw"
            kinit_aftermaxlife "admin" "$pw" $temppw
            # set password policy to allow admin change password right away
            min=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2`
            min=`echo $min`
            history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2`
            history=`echo $history`
            classses=`ipa pwpolicy-show | grep "classes" | cut -d":" -f2`
            classes=`echo $classes`
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=0 --history=0 --minclasses=0
            # now set admin password back to original password
            echo "set timeout 10" > $exp
            echo "set force_conservative 0" >> $exp
            echo "set send_slow {1 .01}" >> $exp
            echo "spawn ipa passwd admin" >> $exp
            echo 'expect "Current Password: "' >> $exp
            echo "send -s -- $temppw\r" >> $exp
            echo 'expect "New Password: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect "Enter New Password again to verify: "' >> $exp
            echo "send -s -- $pw\r" >> $exp
            echo 'expect eof' >> $exp
            /usr/bin/expect $exp 
            cat $exp
            rm $exp
            # after reset password, test the new password
            $kdestroy
            echo $pw | kinit admin
            if [ $? = 1 ];then
                echo "[Local_KinitAsAdmin] reset password back to original [$pw] failed"
            fi
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$min --history=$history --minclasses=$classes           
            echo "[Local_KinitAsAdmin] set admin password back to [$pw] success -- after set to temp"
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
        then
            echo "[Local_KinitAsAdmin] admin password wrong? [$pw]"
        else
            echo "[Local_KinitAsAdmin] unhandled error"
        fi
    else
        echo "[Local_KinitAsAdmin] unknow error, return code [$?] not recoginzed"
    fi
    rm $out
} #KinitAsAdmin

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$tmpdir/kinitaftermaxlife.$RANDOM.exp
    echo "set timeout 10" > $exp
    echo "set force_conservative 0" >> $exp
    echo "set send_slow {1 .01}" >> $exp
    echo "spawn kinit -V $username" >> $exp
    echo 'match_max 100000' >> $exp
    echo 'expect "*: "' >> $exp
    echo "send -s -- $pw\r" >> $exp
    echo 'expect "Password expired. You must change it now."' >> $exp
    echo 'expect "Enter new password: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect "Enter it again: "' >> $exp
    echo "send -s -- $newpw\r" >> $exp
    echo 'expect eof' >> $exp
    echo "$kdestroy"

    echo "====== [kinit_aftermaxlife] exp file ========="
    cat $exp
    echo "----------- ipactl status -------------------"
    ipactl status
    echo "=============================================="
    /usr/bin/expect $exp
    echo "$kdestroy"

    echo "====== [kinit_aftermaxlife] ipactl status after run exp file ========="
    ipactl status
    echo "=============================================="

    echo $newpw | kinit $username
    # clean up
    rm $exp
} #kinit_aftermaxlife


#echo $pw | kinit admin 2>&1 >/dev/null
Local_KinitAsAdmin $pw
klist | grep "admin"

