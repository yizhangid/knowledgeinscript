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

runlevelFile="/lib/systemd/system/runlevel${runlevel}.target"
targetFile="/etc/systemd/system/default.target"

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
