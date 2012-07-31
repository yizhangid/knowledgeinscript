#!/bin/bash
# script : change.runlevel.sh
# date   : 2012.07.31
# author : Yi Zhang
#
# license: GPL v2 please check COPYRIGHT.txt for details
#
# description: change default runlevel based on user input

runlevel=$1
if [ "$runlevel" = "" ];then
	echo -n "set runlevel (0-6), 3 multiuser console; 5 graphical desktop (default 5) "
    read runlevel
    if [ "$runlevel" = "" ];then
        runlevel=5
    fi
fi

if [[ $runlevel != [0-9]* ]] ;then
    echo "runlevel has to be an integer within [0-6]"
    exit 1
elif [ $runlevel -gt 6 ] || [ $runlevel -lt 0 ]
then
    echo "no such run level, please use integer within [0-6]"
    exit 1
else
    runlevelFile="/lib/systemd/system/runlevel${runlevel}.target"
    targetFile="/etc/systemd/system/default.target"

    if [ ! -f $runlevelFile ];then
        echo "runlevel file not found, please check [$runlevelFile]"
        exit 1
    else
        cmd="ln -sf $runlevelFile $targetFile"
        echo "command: $cmd"
        if $cmd
        then
            echo "success !!"
            ls -l $targetFile
            echo ""
        else
            echo "failed !!"
        fi
    fi
fi
