#!/bin/bash
# script : random.i18n.string.sh
# date   : 2012.10.08
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
# 
#   this script will return a randomly selected i18n string from fixed data set ($i18n)

i18n="北京 Gérard Jürgen माधुरी दीक्षित     भारत  林原 めぐみ 심은하 Ľudovít Сәмәдоғлу Һејдәр Céline Dion Antonín Dvořák Mika Häkkinen François Νταλάρας Tor Åge Bringsværd"
random=`expr $RANDOM % 23 + 1`
echo  $i18n | cut -d" " -f$random
