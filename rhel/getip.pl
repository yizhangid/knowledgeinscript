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
our $linux_cmd_output;
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
    our @list_of_ips = sort keys %ips;
    if ( $#list_of_ips >= 0 ){
        print "@list_of_ips";
    }else{
        print "Can not resolve hostname [$hostname] with linux commands: 'host', 'nslookup $hostname'";
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
    $linux_cmd_output = `host $hostname`;
    my @lines=split(/\n/,$linux_cmd_output);
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
    $linux_cmd_output = `nslookup $hostname`;
    my @lines=split(/\n/,$linux_cmd_output);
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
    $linux_cmd_output = `nslookup -query=AAAA $hostname`;
    my @lines=split(/\n/,$linux_cmd_output);
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
    $linux_cmd_output = `/sbin/ifconfig`;
    my @lines=split (/\n/, $linux_cmd_output);
    my %nic;
    my $currentInterface;
    foreach my $line (@lines){
        if ($line =~ /^(\S+)[\s|\t]+Link encap/){
            #br0       Link encap:Ethernet  HWaddr 00:21:9B:32:85:6A (rhel)
            my $interface=$1;
            $currentInterface = $interface;
            #print "\n$interface\t:";
        }elsif($line =~ /^(\S+)[\s|\t]+flags/){
            #eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500 (fedora)
            my $interface=$1;
            $currentInterface = $interface;
            #print "\n$interface\t:";
        }
        elsif ($line =~ /inet (addr:|)(\d+)\.(\d+).(\d+)\.(\d+) /){
            #inet addr:10.14.16.25  Bcast:10.14.16.255  Mask:255.255.255.0 (rhel)
            #inet 10.14.16.171  netmask 255.255.255.0  broadcast 10.14.16.255 (fedora)
            my $ipv4;
            if (( $1 eq "addr:") || ($1 eq "" ) ){
                $ipv4 = "$2.$3.$4.$5";
            }else{ 
                $ipv4 = "$1.$2.$3.$4";
            }
            #print " [ipv4:$ipv4]";
            if (defined $currentInterface && exists $nic{$currentInterface}){
                my $existingValue = $nic{$currentInterface};
                $nic{$currentInterface} = $existingValue." ".$ipv4 ;
            }elsif (defined $currentInterface) {
                $nic{$currentInterface} = $ipv4 ;
            }
        }
        elsif ($line =~ /inet6 (addr: |)([0-9|a-f|:|\/]+) /){
            #inet6 addr: fe80::221:9bff:fe32:856a/64 Scope:Link (rhel)
            #inet6 fe80::5054:ff:fe8e:ad46  prefixlen 64  scopeid 0x20<link> (fedora)
            my $ipv6;
            if (( $1 eq "addr: ") || ($1 eq "" ) ){
                $ipv6 = "$2";
            }else{
                $ipv6 = "$1";
            }
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
