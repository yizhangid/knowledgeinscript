#!/bin/bash
# script : replace.oneline.sh
# date   : 2012.10.23
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

usage()
{
    echo "usage: $0 -f <file to be changes> -o <original line> -n <new line>"
}

paramMsg="$0 "
while getopts "f:o:n:" opt;   do
    case $opt in #------------^^^  "opt" is defined in "while" statement"
    f)
        file=$OPTARG  # bash will do automatic shift for u
        paramMsg="$paramMsg -f [$file]"
        ;;
    o)
        oldLine=$OPTARG # always use $OPTARG
        paramMsg="$paramMsg -o [$oldLine]"
        ;;                                                                                              
    n)                                                                                                  
        newLine=$OPTARG # always use $OPTARG
        paramMsg="$paramMsg -n [$newLine]"                                                         
        ;;
    \?)
        paramMsg="$0 :ERROR: invalid options: -$OPTARG "
        echo "$paramMsg"
        usage
        exit
        ;;                                                                                              
    esac                                                                                                
done

if [ ! -f $file ];then
    echo "file does not exist"
    exit
fi

if [ ! -w $file ];then
    echo "file is not writable"
    exit
fi

if [ "$file" != "" ] && [ "$oldLine" != "" ] && [ "$newLine" != "" ];then
    changeTo="#$oldLine\n$newLine"
    id=$RANDOM
    tmp="/tmp/replace.oneline.$id.txt"
    backup="/tmp/replace.oneline.$id.original.txt"
    if sed -e "s/^$oldLine$/$changeTo/" $file > $tmp
    then
        cp $file $backup
        cp -r $tmp $file
    else
        echo "something wrong, no change made"
    fi
fi

