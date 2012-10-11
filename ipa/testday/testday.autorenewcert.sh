#!/bin/bash
# script : testday.autorenewcert.sh
# date   : 2012.10.11
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

dir=$( cd "$( dirname "$0" )" && pwd )

########## important variables, modify it before start test
ROOTDN="cn=directory manager"
ROOTDNPW="rootDNSecret"
ADMINID="admin"
ADMINPW="adminSecret"
host=`hostname`
CAINSTANCE="pki-ca" # this is fixed variables, no need to change

# helping tools used for this test
ldapsearch="/usr/bin/ldapsearch"
readCert="$dir/readLoadedCert.pl"
sortlist="$dir/sortlist.pl"
grouplist="$dir/grouplist.pl"
countlist="$dir/countlist.pl"
difflist="$dir/difflist.pl"
testResult="/tmp/test.result.$RANDOM.txt"

# constance used for cert autorenew test
sixdays=518400
oneday=86400 
halfday=43200
sixhour=21600
onehour=3600
halfhour=1800
wait4renew=10
maxwait=`echo "$wait4renew * 12" | bc`
continueTest="no"
allcerts="oscpSubsystemCert caSSLServiceCert caSubsystemCert caAuditLogCert ipaAgentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd"
notRenewedCerts="$allcerts"
soonTobeRenewedCerts=""
justRenewedCerts=""
renewedCerts=""
checkTestConditionRequired="true"

######################################################
#   functions 
######################################################
oscpSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="ocspSigningCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caSSLServiceCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="Server-Cert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caSubsystemCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="subsystemCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caAuditLogCert(){
    local db="/var/lib/$CAINSTANCE/alias"
    local nickname="auditSigningCert cert-$CAINSTANCE"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaAgentCert(){
    local db="/etc/httpd/alias"
    local nickname="ipaCert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_ds(){
    local db="/etc/dirsrv/$DSINSTANCE"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_pki(){
    local db="/etc/dirsrv/$CA_DSINSTANCE"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

ipaServiceCert_httpd(){
    local db="/etc/httpd/alias"
    local nickname="Server-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

caJarSigningCert(){
    local db="/etc/httpd/alias"
    local nickname="Signing-Cert"
    local state=$2
    if [ "$state" = "" ];then
        state="valid"
    fi
    if [ "$1" = "nickname" ];then
        echo $nickname
    elif [ "$1" = "db" ];then
        echo $db
    else
        $readCert -d $db -n "$nickname" -p "$1" -s $state
    fi
}

list_all_ipa_certs(){
    sort_certs
    echo ""
    echo "+-------------------- all IPA certs [`date`]----------------------------------+"
    echo "[preValid certs]:"
    list_certs "preValid" $allcerts
    echo ""

    echo "[valid certs]:"
    list_certs "valid" $allcerts
    echo ""

    echo "[expired certs]:"
    list_certs "expired" $allcerts
    echo "+--------------------------------------------------------------------------------------------------+"
    echo ""
}

list_certs(){
    local state=$1
    shift
    for cert in $@
    do
        print_cert_brief $cert $state
    done
}

print_cert_brief(){
    local cert=$1
    local passinState=$2
    local readState=`$cert status $passinState`
    if [[ "$passinState" =~ ^(preValid|valid|expired)$ ]] ;then
        if [ "$readState" = "$passinState" ];then
            local nickname=`$cert nickname $passinState`
            local serial=`$cert serial $passinState`
            local notbefore_sec=`$cert NotBefore_sec $passinState`
            local notbefore_date=`$cert NotBefore $passinState`
            local notafter_sec=`$cert NotAfter_sec $passinState`
            local notafter_date=`$cert NotAfter $passinState`
            local timeleft=`$cert LifeLeft $passinState`
            local life=`$cert Life $passinState`
            local subject=`$cert subject $passinState`

            local fp_certname=`perl -le "print sprintf (\"%-21s\",\"$cert\")"`
            local name="$fp_certname($nickname)"
            local fp_name=`perl -le "print sprintf (\"%-51s\",\"$name\")"`
            local fp_serial=`perl -le "print sprintf (\"%-2d\",$serial)"`
            local fp_state=`perl -le "print sprintf (\"%-8s\",$passinState)"`
            local fp_timeleft=`perl -le "print sprintf(\"%-20s\",\"$timeleft\")"`
            echo "$fp_name #$fp_serial: [$notbefore_date]~~[$notafter_date] expires@($fp_timeleft) life [$life] "
        fi
    else
        echo "not supported status :[$passinState]"
    fi
}

print_cert_details(){
    local indent=$1
    local cert=$2
    local state=$3
    local db=`$cert db`
    local nickname=`$cert nickname`
    local tempcertfile="$TmpDir/cert.detail.$RANDOM.txt"
    $readCert -d $db -n "$nickname" -s $state -f $tempcertfile 2>&1 >/dev/null
    if [ -f $tempcertfile ];then
        echo "$indent+-------------------------------------------------------------------------------+"
        cat $tempcertfile | sed -e "s/^\w/$indent | &/"
        echo "$indent+-------------------------------------------------------------------------------+"
        rm $tempcertfile
    fi
    echo ""
}

max(){
    local max=$1
    shift
    for n in $@
    do
        if [ $max -lt $n ];then
            max=$n
        fi
    done
    echo $max
}

min(){
    local min=$1
    shift
    for n in $@
    do
        if [ $min -gt $n ];then
            min=$n
        fi
    done
    echo $min
} 

get_not_before_sec(){
    local state=$1
    shift
    local notBefore=""
    for cert in $@
    do
        local notBefore_epoch=`$cert "NotBefore_sec" $state`
        if [ "$notBefore_epoch" != "no cert found" ];then
            notBefore="$notBefore $notBefore_epoch"
        fi
    done
    echo $notBefore
}

get_not_after_sec(){
    local state=$1
    shift
    local notAfter=""
    for cert in $@
    do
        local notAfter_epoch=`$cert "NotAfter_sec" $state`
        if [ "$notAfter_epoch" != "no cert found" ];then
            notAfter="$notAfter $notAfter_epoch"
        fi
    done
    echo $notAfter
}

convert_utc_date_to_epoch(){
    date -d "$@ UTC" "+%s"
}

convert_date_to_epoch(){
    date -d "$@" "+%s"
}
    

convert_epoch_to_date(){
    perl -e "print scalar localtime($1)"
}

fix_prevalid_cert_problem(){
    local before=`get_not_before_sec "preValid" $allcerts `
    echo "fix_prevalid_cert_problem"
    echo "+----------------- check prevalid problem -----------------+"
    echo -n "[fix_prevalid_cert_problem]"
    if [ "$before" = "" ];then
        echo " no preValid problem found"
    else
        echo " found previlid problem, fixing..."
        list_certs "preValid" $allcerts
        local before_max=`max $before`
        local now=`date`
        local now_epoch=`convert_date_to_epoch "$now"`
        echo "      current time   : $now"
        echo "      cert not-before: `convert_epoch_to_date $before_max`"
        if [ $now_epoch -lt $before_max ];then
            adjust_system_time $before_max preValid
        fi 
    fi
    echo "+----------------------------------------------------------+"
}

calculate_autorenew_date(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - calculate_autorenew_date"
    local group=$@
    local after=`get_not_after_sec valid $group`
    local after_min=`min $after`
    local after_max=`max $after`
    local current_epoch=`date +%s`
    certExpire=`min $after`
    preAutorenew=`echo "$certExpire - $oneday" | bc`
    autorenew=`echo "$certExpire - $sixdays" | bc`
    postAutorenew=`echo "$certExpire - $halfhour " | bc`
    postExpire=`echo "$certExpire + $halfday" | bc`
    echo "     current date :" `date` "($current_epoch)"
    echo "     autorenew    :" `convert_epoch_to_date $autorenew` " ($autorenew)"  
    echo "     certExpire   :" `convert_epoch_to_date $certExpire` " ($certExpire)" 
    echo "     postExpire   :" `convert_epoch_to_date $postExpire` " ($postExpire)" 
    echo ""
    if [ $current_epoch -lt $autorenew ] \
        && [ $autorenew -lt $certExpire ] \
        && [ $certExpire -lt $postExpire ]
    then
        echo "Pass: got reasonable autorenew time"
    else
        echo "Fail: something wrong, date are not well ordered"
    fi
    echo "$FUNCNAME finished"
}

adjust_system_time(){
    local adjustTo=$1
    local label=$2
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - adjust_system_time $label"
    echo "[adjust_system_time] ($label) : given [$adjustTo]" `convert_epoch_to_date $adjustTo`
    local before=`date`
    date "+%a %b %e %H:%M:%S %Y" -s "`perl -le "print scalar localtime $adjustTo"`" 2>&1 > /dev/null
    if [ "$?" = "0" ];then
        local after=`date`
        echo "PASS, adjust ($label) [$before]=>[$after] done"
    else
        local after=`date`
        echo "Fail, change date failed, current data: [`date`]"
    fi
    echo "$FUNCNAME finished"
}

stop_ipa_server(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - stop_ipa_server ($@)"
    local out=`ipactl stop 2>&1`
    sleep 5 # give system some time so ipa server can fully stopped
    if echo $out | grep "Aborting ipactl"
    then
        echo "stop ipa server Failed"
    else
        echo "stop ipa server Success"
    fi
    echo "$FUNCNAME finished"
}

start_ipa_server(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - start_ipa_server ($@)" 
    local out=`ipactl start 2>&1`
    sleep 5 # give system some time so ipa server can fully stopped
    if echo $out | grep "Aborting ipactl"
    then
        echo "start ipa server Failed"
    else
        echo "start ipa server Success"
    fi
    echo "$FUNCNAME finished"
}

go_to_sleep(){
    local waittime=0
    echo ""
    echo -n "[go_to_sleep] $maxwait(s): "
    while [ $waittime -lt $maxwait ]
    do    
        waittime=$((waittime + $wait4renew))
        echo -n " ...$waittime(s)"
        sleep $wait4renew
    done
    echo ""
}

prepare_for_next_round(){
    renewedCerts="$renewedCerts $justRenewedCerts"
    justRenewedCerts="" #reset so we can continue test
    local header="  "
    echo "$header +------------------- Cert Renew report ($testid)-----------------+"
    for cert in $allcerts
    do
        local counter=`$countlist -s "$renewedCerts" -c "$cert"`
        local fp_certname=`perl -le "print sprintf (\"%+26s\",\"$cert\")"`
        echo "$header | $fp_certname : renewed [ $counter ] times         |"
    done
    echo "$header +----------------------------------------------------------+"
}

check_actually_renewed_certs(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - check_actually_renewed_certs"
    local certsShouldBeRenewed=$@
    for cert in $certsShouldBeRenewed
    do
        local state=`$cert status valid`
        if [ "$state" = "valid" ];then
            echo "PASS: valid cert found for  [$cert]"
            justRenewedCerts="${justRenewedCerts}${cert} " #append spaces at end
        else
            echo "FAIL: NO valid cert found for [$cert]"
        fi
    done
    echo "$FUNCNAME finished"
}

compare_expected_renewal_certs_with_actual_renewed_certs(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - compare_expected_renewal_certs_with_actual_renewed_certs"
    echo "[soon to be renewed certs]: [$soonTobeRenewedCerts]"
    echo "[acutally being renewed  ]: [$justRenewedCerts]"
    echo ""
    if [ "$soonTobeRenewedCerts " = "$justRenewedCerts " ];then # don't forget the extra spaces
        echo "PASS round [$testid] renewed certs: [$soonTobeRenewedCerts]"
        echo "    [ PASS ] -- compare_expected_renewal_certs_with_actual_renewed_certs ($@)" >> $testResult
    else
        local difflist=`$difflist "$soonTobeRenewedCerts" "$justRenewedCerts"`
        echo "FAIL round [$testid] certs not renewed [ $difflist ]"
        echo "    [ FAIL ] -- compare_expected_renewal_certs_with_actual_renewed_certs ($@)" >> $testResult
        echo "current system time :[`date`]"
        for cert in $difflist
        do
            print_cert_details "     " $cert expired
            print_cert_details "     " $cert preValid
        done
    fi
    echo "$FUNCNAME finished"
}

test_status_report(){
    if [ -f $testReport ];then
        echo ""
        echo "#-------------- autorenewcert test status report round($testid) -------------------------------#"
        cat $testResult
        echo "#----------------------------------------------------------------------------------------#"
        echo ""
    fi
}

pause(){
    local choice="y"
    echo -n "continue? (y/n) "
    read choice
    if [ "$choice" = "n" ];then
        exit
    fi
}

sort_certs(){
    local tempdatafile="$TmpDir/cert.timeleft.$RANDOM.txt"
    echo "[sort_certs] sorted by cert timeLeft_sec: "
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        else
            timeleft_sec=`$cert LifeLeft_sec preValid`
            if [ "$timeleft_sec" != "no cert found" ];then
                echo "$cert=$timeleft_sec" >> $tempdatafile 
            else
                timeleft_sec=`$cert LifeLeft_sec expired`
                echo "$cert=$timeleft_sec" >> $tempdatafile
            fi
        fi
    done
    if [ -f $tempdatafile ];then
        allcerts=`$sortlist $tempdatafile`
        echo " [$allcerts]"
        rm $tempdatafile
    fi   
}

find_soon_to_be_renewed_certs(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - find_soon_to_be_renewed_certs"
    echo "find_soon_to_be_renewed_certs"
    local tempdatafile="$TmpDir/cert.timeleft.$RANDOM.txt"
    for cert in $allcerts
    do
        local timeleft_sec=`$cert LifeLeft_sec valid`
        if [ "$timeleft_sec" != "no cert found" ];then
            echo "$cert=$timeleft_sec" >> $tempdatafile
        fi
    done
    if [ -f $tempdatafile ];then
        soonTobeRenewedCerts=`$grouplist "$tempdatafile" "$halfhour"`
        rm $tempdatafile
        echo "PASS : found [$soonTobeRenewedCerts]"
    else
        echo "FAIL : no cert found to test: [$soonTobeRenewedCerts]"
    fi
    echo "$FUNCNAME finished"
}

continue_test(){
    if [ ! -f $testResult ];then
        touch $testResult
        echo "yes" # when test gets into first round, there is no testResult file exist, just echo 'yes' to continue test
    else
        if ! grep "FAIL" $testResult 2>&1 >/dev/null
        then
            echo "yes"
        fi
    fi
}

get_all_valid_certs(){
    local validCerts=""
    for cert in $allcerts
    do
        state=`$cert status valid`
        if [ "$state" = "valid" ];then
            validCerts="$validCerts $cert"
        fi
    done
    echo "$validCerts"
}

final_cert_status_report(){
    # we stop test in the following 2 conditions
    # 1. previous test result has to pass
    # 2. there are some certs haven't get chance to be renewed
   
    # check condition 1:
    notRenewedCerts=`$difflist "$renewedCerts" "$allcerts"`
    local validCerts=`get_all_valid_certs`
    local notValid=`$difflist "$validCerts" "$allcerts"`
    echo ""
    echo "######################################################################################################################"
    echo "#                                                                                                                    #"
    echo "#                                        Final IPA Cert Status Report                                                #"
    echo "#--------------------------------------------------------------------------------------------------------------------#"
    echo "[all certs  ] [$allcerts]"
    echo "[valid certs] [$validCerts]"
    echo "[not valid  ] [$notValid]"
    list_all_ipa_certs
    for cert in $notValid
    do
        echo "   No valid certs found for [$cert]"
        local db=`$cert db`
        local nickname=`$cert nickname`
        echo "      debug [certutil -L -d $db -n \"$nickname\"] "
        echo "      OR    [$readCert -d $db -n \"$nickname\" -s (preValid/valid/expired)]"
        print_cert_details "     " $cert preValid
        print_cert_details "     " $cert expired
    done
    test_status_report
    echo "######################################################################################################################"
    echo ""
}

print_test_header(){
    echo ""
    echo "###########################################################"
    echo "#                                                         #"
    echo "#                    test round [$testid]                       #"
    echo "#                                                         #"
    echo "###########################################################"
    echo ""
}

test_ipa_via_kinit_as_admin(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - test_ipa_via_kinit_as_admin ($@)"
    local pw=$ADMINPW
    local out=$TmpDir/kinit.as.admin.$RANDOM.txt
    echo "[test_ipa_via_kinit_as_admin] test with password: [$pw]: echo $pw | kinit $ADMINID"
    echo $pw | kinit $ADMINID 2>&1 > $out
    if [ $? = 0 ];then
        echo "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success"
        echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
    elif [ $? = 1 ];then
        echo "[test_ipa_via_kinit_as_admin] first try of kinit as $ADMINID with [$pw] failed"
        echo "[test_ipa_via_kinit_as_admin] check ipactl status"
        ipactl status
        if echo $pw | kinit $ADMINID | grep -i "kinit: Generic error (see e-text) while getting initial credentials"
        then
            echo "[test_ipa_via_kinit_as_admin] got kinit: Generic error, restart ipa and try same password again"
            ipactl restart
            $kdestroy
            echo $pw | kinit $ADMINID 2>&1 > $out
            if [ $? = 0 ];then
                echo "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] success at second attempt -- after restart ipa"
                echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
                return
            else
                echo "[test_ipa_via_kinit_as_admin] kinit as $ADMINID with [$pw] failed at second attempt -- after restart ipa, continue trying"
            fi
        fi
            
        echo "[test_ipa_via_kinit_as_admin] password [$pw] failed, check whether it is because password expired"
        echo "#------------ output of [echo $pw | kinit $ADMINID] ------------#"
        cat $out
        echo "#----------------------------------------------------------------#"
        if grep "Password expired" $out 2>&1 >/dev/null
        then
            echo "$ADMINID password exipred, do reset process"
            local exp=$TmpDir/reset.admin.password.$RANDOM.exp
            local temppw="New_$pw"
            kinit_aftermaxlife "$ADMINID" "$ADMINPW" "$temppw"
            # set password policy to allow $ADMINID change password right away
            local minlife=`ipa pwpolicy-show | grep "Min lifetime" | cut -d":" -f2| xargs echo`
            local history=`ipa pwpolicy-show | grep "History size" | cut -d":" -f2| xargs echo`
            classses=`ipa pwpolicy-show | grep "classes" | cut -d":" -f2`
            classes=`echo $classes`
            ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=0 --history=0 --minclasses=0
            # now set $ADMINID password back to original password
            echo "set timeout 10" > $exp
            echo "set force_conservative 0" >> $exp
            echo "set send_slow {1 .01}" >> $exp
            echo "spawn ipa passwd $ADMINID" >> $exp
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
            echo $pw | kinit $ADMINID
            if [ $? = 1 ];then
                echo "[test_ipa_via_kinit_as_admin] reset password back to original [$pw] failed"
                echo "    [ FAIL ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
            else
                echo "[test_ipa_via_kinit_as_admin] reset password success"
                echo "    [ PASS ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
                ipa pwpolicy-mod --maxfail=0 --failinterval=0 --lockouttime=0 --minlife=$minlife --history=$history --minclasses=$classes
                echo "[test_ipa_via_kinit_as_admin] set $ADMINID password back to [$pw] success -- after set to temp"
            fi
        elif grep "Password incorrect while getting initial credentials" $out 2>&1 >/dev/null
        then
            echo "[test_ipa_via_kinit_as_admin] wrong $ADMINID password provided: [$pw]"
            echo "  FAIL: test_ipa_via_kinit_as_admin ($@)" >> $testResult
        else
            echo "[test_ipa_via_kinit_as_admin] unhandled error: Not because password expired; not because wrong password provided"
            echo "    [ FAIL ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
        fi
    else
        echo "[test_ipa_via_kinit_as_admin] unknow error, return code [$?] not recoginzed"
        echo "    [ FAIL ] test_ipa_via_kinit_as_admin ($@)" >> $testResult
    fi
    rm $out
    echo "$FUNCNAME finished"
}

kinit_aftermaxlife()
{
    local username=$1
    local pw=$2
    local newpw=$3
    local exp=$TmpDir/kinitaftermaxlife.$RANDOM.exp
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
    /usr/bin/expect $exp

    echo "kinit as [$username] with new password [$newpw]"
    echo $newpw | kinit $username
    if [ "$?" = "0" ];then
        echo "[kinit_aftermaxlife] kinit success"
    else
        echo "[kinit_aftermaxlife] kinit failed, please check the exp file"
        echo "#------ [kinit_aftermaxlife] exp file -------#" 
        cat $exp
        echo "#----------- ipactl status -------------------#"
        ipactl status
        echo "#---------------------------------------------#"
    fi
    rm $exp
} #kinit_aftermaxlife



test_dirsrv_via_ssl_based_ldapsearch(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - test_dirsrv_via_ssl_based_ldapsearch ($@)"
    # doc: http://directory.fedoraproject.org/wiki/Howto:SSL#Use_ldapsearch_with_SSL
    local testCMD="$ldapsearch -H ldaps://$host -x -D \"$ROOTDN\" -w \"$ROOTDNPWD\" -s base -b \"\" objectclass=* | grep \"vendorName:\" "
    echo "test command: $testCMD"
    $ldapsearch -H ldaps://$host -x -D "$ROOTDN" -w "$ROOTDNPWD" -s base -b "" objectclass=* | grep "vendorName:" 
    if [ "$?" = "0" ];then
        echo "[test_dirsrv_via_ssl_based_ldapsearch] Test Pass"
        echo "    [ PASS ] test_dirsrv_via_ssl_based_ldapsearch ($@)" >> $testResult
    else
        echo "[test_dirsrv_via_ssl_based_ldapsearch] Test Failed"
        echo "    [ FAIL ] test_dirsrv_via_ssl_based_ldapsearch ($@)" >> $testResult
    fi
    echo ""
    echo "$FUNCNAME finished"
}

test_dogtag_via_cert_show(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - test_dogtag_via_cert_show ($@)"
    local certid=1
    local testCMD="ipa cert-show $certid | grep 'Certificate:'"
    echo "test command : $testCMD"
    ipa cert-show $certid | grep 'Certificate:'
    if [ "$?" = "0" ];then
        echo "[test_dogtag_via_cert_show] Test Pass"
        echo "    [ PASS ] test_dogtag_via_cert_show ($@)" >> $testResult
    else
        echo "[test_dogtag_via_cert_show] Test Failed"
        echo "    [ FAIL ] test_dogtag_via_cert_show ($@)" >> $testResult
    fi
    echo ""
    echo "$FUNCNAME finished"
}

find_dirsrv_instance(){
    local asking=$1
    local all=`ls -d /etc/dirsrv/slapd-*`
    local ca_ds_instance=""
    local ds_instance=""
    # determine dirsrv instance name
    for name in $all
    do
        basename=`basename $name`
        if [[ $name =~ "PKI-IPA" ]];then
            ca_ds_instance=$basename
        else
            ds_instance=$basename
        fi
    done
    if [ "$asking" = "ca" ];then
        echo $ca_ds_instance
    elif [ "$asking" = "ds" ];then
        echo "$ds_instance"
    fi
}

test_ipa_via_creating_new_cert(){
    echo "$FUNCNAME starts "  "autorenewcert round [$testid] - test_ipa_via_creating_new_cert ($@)"
    local serviceName=testservice_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key
    local principal=$serviceName/$host
    echo "certreq    [$certRequestFile]"
    echo "privatekey [$certPrivateKeyFile]"
    echo "principal  [$principal]"

    #requires : kinit as admin to success 
    echo "[step 1/4] create/add a host this should already done : use existing host $host"

    echo "[step 2/4] add a test service add service: [$principal]"
    ipa service-add $principal

    echo "[step 3/4] create a cert request"
    create_cert_request_file $certRequestFile $certPrivateKeyFile
    if [ "$?" = "0" ];then
        echo "cert file creation success, continue"
    else
        echo "cert file creation failed, return fail"
        echo "    [ FAIL ] test_ipa_via_creating_new_cert ($@)" >> $testResult
        return
    fi

    echo "[step 4/4] process cert request"
    ipa cert-request --principal=$principal $certRequestFile 
    if [ $? = 0 ];then
        echo "customer cert create success, test pass"
        echo "    [ PASS ] test_ipa_via_creating_new_cert ($@)" >> $testResult
    else
        echo "customer cert create failed, test failed"
        echo "    [ FAIL ] test_ipa_via_creating_new_cert ($@)" >> $testResult
    fi
    echo "$FUNCNAME finished"
}

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    local certCmd="openssl req -out $requestFile -new -newkey rsa:2048 -nodes -keyout $keyFile"
    local exp=$TmpDir/createCertRequestFile.$RANDOM.exp  # local test

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
    echo "send -s -- \"$host\r\"" >> $exp

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

# calculate dynamic variables
DSINSTANCE="`find_dirsrv_instance ds`"
CA_DSINSTANCE="`find_dirsrv_instance ca`"

cert_sanity_check(){
    test_ipa_via_kinit_as_admin "$@"
    test_dirsrv_via_ssl_based_ldapsearch "$@"
    test_dogtag_via_cert_show "$@"
    test_ipa_via_creating_new_cert "$@"
}

autorenewcert()
{
        print_test_header
        cert_sanity_check "Before auto renew triggered"
        pause
        calculate_autorenew_date $soonTobeRenewedCerts

        pause
        stop_ipa_server "Before autorenew"
        adjust_system_time $autorenew autorenew    
        start_ipa_server "After autorenew"

        pause
        go_to_sleep

        stop_ipa_server "Before postExpire"
        adjust_system_time $postExpire postExpire
        start_ipa_server "After postExpire"

        pause
        check_actually_renewed_certs $soonTobeRenewedCerts
        compare_expected_renewal_certs_with_actual_renewed_certs "After postExpire"

        cert_sanity_check  "After auto renew triggered"
        test_status_report 
}

#########################################
#              main test                #
#########################################
main_autorenewcert_test(){
    testid=1
    fix_prevalid_cert_problem #weird problem
    # conditions for test to continue (continue_test returns "yes")
    # 1. all ipa certs are valid
    # 2. if there are some certs haven't get chance to be renewed, test should be continue

    while [ "`continue_test`" = "yes" ]
    do
        echo "" > $testResult  # reset test result from last round
        list_all_ipa_certs
        find_soon_to_be_renewed_certs
        autorenewcert $round
        prepare_for_next_round
        testid=$((testid + 1))
        #fix_prevalid_cert_problem #weird problem
    done
    final_cert_status_report 
}
################ end of main ###########

main_autorenewcert_test
