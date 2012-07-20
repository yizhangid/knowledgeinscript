#!/usr/bin/perl
# script : getip.pl
# date   : 2012.07.18
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#
# description: use linux command `host` and `nslookup` to get hostname's ip address

use warnings;
use strict;
use Getopt::Std;

###########################################
#          global variables               #
###########################################
our $hostname;
our $alias;
our $info;
our %ips;

###########################################
#     command line argument parsing       #
###########################################
if ( $#ARGV < 0){
    $hostname="localhost";
}elsif ( $#ARGV == 0 ) {
    $hostname=$ARGV[0];
}else{
    exit 0;
}

# START #

do_host();
do_nslookup();
our @list = sort keys %ips;
if ( $#list >= 0 ){
    print "@list";
}else{
    print "Can not resolve";
}
print "\n";

# END #

###########################################
#             subroutines                 #
###########################################

sub do_host
{
    $info = `host $hostname`;
    my @lines=split(/\n/,$info);
    my @ips;
    foreach my $line (@lines){
        if ($line =~ /has address (\d+)\.(\d+).(\d+)\.(\d+)/){
            my $ip = "$1.$2.$3.$4";
            #print "\nhost: $ip";
            if (! exists $ips{$ip}){
                $ips{$ip} = 1;
            }
        }
    }
}

sub do_nslookup
{
    $info = `nslookup $hostname`;
    my @lines=split(/\n/,$info);
    my @ips;
    foreach my $line (@lines){
        if ($line =~ /Address: (\d+)\.(\d+).(\d+)\.(\d+)/){
            my $ip = "$1.$2.$3.$4";
            #print "\nnslookup: $ip";
            if (! exists $ips{$ip}){
                $ips{$ip} = 1;
            }
        }
    }
}
