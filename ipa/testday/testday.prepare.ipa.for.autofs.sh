#!/bin/bash
# script : testday.prepare.ipa.for.autofs.sh
# date   : 2012.10.11
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

show_autofs_configuration(){
    local locationName=$1
    echo ""
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "      autofs configuration for location [$locationName]"
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    ipa automountlocation-tofiles $name
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo ""
}

how_to_check_autofs_mounting(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="$autofsTopDir/$autofsSubDir"
    echo "to delete this configuration: ipa automountlocation-del $name"
    echo "to use this autofs configuration: "
    echo "  (1) ipa-client-automount --server=$nfsHost --location=$name"
    echo "  (2) autofs should be automatic restart, if not, do 'systemctl restart autofs'"
    echo "  (3) to use this mount location: do 'cd $autofsDir' on nfs client (where autofs runs)"
}

configure_autofs_indirect2(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir="${autofsTopDir}/${autofsSubDir}"
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountmap-add-indirect $name auto.share --mount=${autofsTopDir} --parentmap=auto.master
    ipa automountkey-add $name auto.share --key=${autofsSubDir} --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

configure_autofs_direct(){
    local name=$1
    local nfsHost=$2
    local nfsDir=$3
    local autofsDir=$4
    echo "location [$name] : nfs server [$nfsHost] : nfs dir [$nfsDir] : autofs local dir [$autofsDir] "
    ipa automountlocation-add $name
    ipa automountkey-add $name auto.direct --key=$autofsDir --info="-ro,soft,rsize=8192,wsize=8192 ${nfsHost}:${nfsDir}"
    show_autofs_configuration $name
    how_to_check_autofs_mounting $name $nfsHost $nfsDir $autofsDir
}

usage(){
    echo " -------- "
    echo "| USAGE: |"
    echo "|  $0 -n <automount location name> -s <nfs server> -d <nfs shared directory> -m <map type: direct/indirect>  |"
    echo " ----------------------------------------------------------------------------------------------------------------------- "
}

id=$RANDOM
automountLocationName="yztest${id}"
maptype="indirect"
nfsServer="f17apple.yzhang.redhat.com"
nfsSharedDir="/share/pub"
autofsTopDir="/ipashare${id}"

paramMsg="configure ipa automount using "
while getopts ":n:s:d:m:" opt ;do
    case $opt in
    n)
        automountLocationName=$OPTARG
        paramMsg="$paramMsg -n [$automountLocationName]"
        ;;
    s)
        nfsServer=$OPTARG
        paramMsg="$paramMsg -s [$nfsServer]"
        ;;
    d)
        nfsSharedDir=$OPTARG
        paramMsg="$paramMsg -d [$nfsSharedDir]"
        ;;
    m)
        maptype=$OPTARG
        paramMsg="$paramMsg -m [$maptype]"
        ;;
    \?)
        paramMsg="$0 :ERROR: invalid options: -$OPTARG "
        usage
        echo "$paramMsg" 
        exit
        ;;
    esac
done

if [ "$automountLocationName" != "" ] \
    && [ "$nfsServer" != "" ] \
    && [ "$nfsSharedDir" != "" ] \
    && [ "$autofsTopDir" != "" ] \
    && [ "$maptype" != "" ]
then
    autofsSubDir="ipapublic${id}"
    autofsDir="$autofsTopDir/$autofsSubDir"
    if [ "$maptype" = "direct" ];then
        configure_autofs_direct $automountLocationName $nfsServer $nfsSharedDir $autofsDir
    elif [ "$maptype" = "indirect" ];then
        configure_autofs_indirect2 $automountLocationName $nfsServer $nfsSharedDir
    else
        echo "wrong map type, please use 'direct' or 'indirect'"
    fi
else
    echo "please check your input parameters and values: $paramMsg"
    usage
    exit
fi

