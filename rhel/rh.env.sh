#!/bin/bash
# script : rh.env.sh
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

tmp=/tmp/rh.env.$RANDOM.sh

echo "
####### rh.env.sh settings ######
alias vi='vim'
alias ll='ls -l'
alias grep='grep --color=auto '
alias re.source=\"source /etc/bashrc ; source ~/.bashrc\"
processor=`uname -i`
rhversion=`cat /etc/redhat-release | cut -d" " -f7`
PS1=\"[\u@\h (rh \${rhversion}-\${processor}) \W] \"
SVN_EDITOR=vim
export SVN_EDITOR PS1
####### `date` ######
" > $tmp

bashrc="/etc/bashrc"

if grep "rh.env.sh settings" $bashrc 2>&1 >/dev/null
then
    echo "rh.env.sh setting already in place, do nothing"
else
    echo "------- preparing rh env settings -------"
    cat $tmp
    echo "-----------------------------------------"
    echo "insert into $bashrc"
    cat $tmp >> $bashrc
    if [ "$?" = "0" ];then
        echo "success"
        cat $bashrc
    else
        echo "failed"
    fi
fi
rm $tmp

echo "please do \"source $bashrc\" after this script finished running"
