#!/usr/bin/perl
# script : getip.pl
# date   : 2012.07.18
# author : Yi Zhang
#
# license: GPL v2 please check COPYRIGHT.txt for details
#
# description: use linux command `host` and `nslookup` to get ip address for given hostname, if no hostname given, then report ip for 'localhost'

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
    do_localhost();
}elsif ( $#ARGV == 0 ) {
    $hostname=$ARGV[0];
    do_host();
    do_nslookup_ipv6();
    do_nslookup_ipv4();
    our @list = sort keys %ips;
    if ( $#list >= 0 ){
        print "@list";
    }else{
        print "Can not resolve";
    }
    print "\n";
}else{
    exit 0;
}

###########################################
#             subroutines                 #
###########################################

sub do_host
{
    $info = `host $hostname`;
    my @lines=split(/\n/,$info);
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

sub do_nslookup_ipv4
{
    $info = `nslookup $hostname`;
    my @lines=split(/\n/,$info);
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

sub do_nslookup_ipv6
{
    $info = `nslookup -query=AAAA $hostname`;
    my @lines=split(/\n/,$info);
    foreach my $line (@lines){
        if ($line =~ /has AAAA address (.*)$/){
            my $ip = "$1";
            #print "\nnslookup: $ip";
            if (! exists $ips{$ip}){
                $ips{$ip} = 1;
            }
        }
    }
}

sub do_localhost
{
    $info = `/sbin/ifconfig`;
    my @lines=split (/\n/, $info);
    my %nic;
    my $currentInterface;
    foreach my $line (@lines){
        if ($line =~ /^(\S+)[\s|\t]+Link encap/){
            #br0       Link encap:Ethernet  HWaddr 00:21:9B:32:85:6A
            my $interface=$1;
            #print "\n$interface\t:";
            $currentInterface = $interface;
        }
        elsif ($line =~ /inet addr:(\d+)\.(\d+).(\d+)\.(\d+) /){
            #inet addr:10.14.16.25  Bcast:10.14.16.255  Mask:255.255.255.0
            my $ipv4 = "$1.$2.$3.$4";
            #print " [ipv4:$ipv4]";
            if (defined $currentInterface && exists $nic{$currentInterface}){
                my $existingValue = $nic{$currentInterface};
                $nic{$currentInterface} = $existingValue." ".$ipv4 ;
            }elsif (defined $currentInterface) {
                $nic{$currentInterface} = $ipv4 ;
            }
        }
        elsif ($line =~ /inet6 addr: (.*) Scope:Link/){
            #inet6 addr: fe80::221:9bff:fe32:856a/64 Scope:Link
            my $ipv6 = "$1";
            #print " [ipv6:$ipv6]";
            if (defined $currentInterface && exists $nic{$currentInterface}){
                my $existingValue = $nic{$currentInterface};
                $nic{$currentInterface} = $existingValue." ".$ipv6 ;
            }elsif (defined $currentInterface){
                $nic{$currentInterface} = $ipv6 ;
            }
        }else{
            next;
        }
    }
    foreach (sort keys %nic){
        my $interface = $_;
        my $ip = $nic{$interface};
        print "\n$interface\t: $ip";
    }
    print "\n";
}
