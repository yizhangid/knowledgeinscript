#!/bin/bash
# script : log.sh
# date   : 2012.08.22
# author : Yi Zhang
# version: 1.1
#
# license: GPL v2 please check COPYRIGHT.txt for details
#
INFO(){
    log info $@
}

DEBUG(){
    log debug $@
}

log(){
    local loglevel=""
    local logmsg=""
    if [ $# -ge 2 ];then
        loglevel=$1  
        shift
        logmsg=$@
    else           
        logmsg=$@ 
    fi
    local setting=`get_int_level $mode`
    local request=`get_int_level $loglevel`
    if [ $setting -ge $request ];then
        echo "$logmsg"
    fi
}      

get_int_level(){
    # debug=3 ; info=2 ;
    local loglevel=$1
    case $loglevel in
    debug)
        echo 3 ;;
    info)
        echo 2 ;;
    *)
        echo 2 ;;
    esac
}

get_log_level(){
    # debug=3 ; info=2 ;
    local intlevel=$1
    case $intlevel in
    3)
        echo "debug" ;;
    2)
        echo "info" ;;
    *)
        echo "info" ;;
    esac
}

#mode="debug"
mode=info

# test
DEBUG "this is info"

