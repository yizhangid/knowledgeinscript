#!/bin/bash
# script : echoline.sh
# date   : 2012.10.08
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
# 
# when use functions in this script, just do
# . <this script>

# for more colors: http://wiki.bash-hackers.org/scripting/terminalcodes

COLOR_black='\E[30m'
COLOR_red='\E[31m'
COLOR_green='\E[32m'
COLOR_yellow='\E[33m'
COLOR_blue='\E[34m'
COLOR_magenta='\E[35m'
COLOR_cyan='\E[36m'
COLOR_white='\E[37m'

COLOR_redOnWhite='\E[31;47m'
COLOR_redOnYellow='\E[31;43m'
COLOR_greenOnWhite='\E[32;47m'

echoblack()  { echocolor $COLOR_black   "$@"; }
echored()    { echocolor $COLOR_red     "$@"; }
echogreen()  { echocolor $COLOR_green   "$@"; }
echoyellow() { echocolor $COLOR_yellow  "$@"; }
echoblue()   { echocolor $COLOR_blue    "$@"; }
echomagenta(){ echocolor $COLOR_magenta "$@"; }
echocyan()   { echocolor $COLOR_cyan    "$@"; }
echowhite()  { echocolor $COLOR_white   "$@"; }

echoredOnWhite()  { echocolor $COLOR_redOnWhite   "$@"; }
echoredOnYellow() { echocolor $COLOR_redOnYellow  "$@"; }
echogreenOnWhite(){ echocolor $COLOR_greenOnWhite "$@"; }

echoboldgreen(){ 
    echo -n -e "\033[1m"
    echo -n -e $COLOR_green
    echo -n "$@"
    echo -e "\033[0m"
    tput sgr0 
}

echoboldred(){ 
    echo -n -e "\033[1m"
    echo -n -e $COLOR_red
    echo -n "$@"
    echo -e "\033[0m"
    tput sgr0 
}

echocolor(){
    local color=$1
    shift
    local msg="$@"
    echo -n -e $color
    echo $@
    tput sgr0
}

echobold(){
    echo -n -e "\033[1m"
    echo -n $@
    echo -e "\033[0m"
    tput sgr0  #set terminal back to normal
}

# to test, uncomment the following
echored "this is red on default background color"
echogreen "this is green on default background color"
echoyellow "this is yellow on default background color"
echoblue "this is blue on default background color"
echomagenta "this is magenta on default background color"
echocyan "this is cyan on default background color"
echowhite "this is white on default background color"
echoredOnWhite "this is red on white background"
echoredOnYellow "this is red on yellow background"
echogreenOnWhite "this is green on white background"
echoboldgreen "this is bold green"
echoboldred "this is bold red"

