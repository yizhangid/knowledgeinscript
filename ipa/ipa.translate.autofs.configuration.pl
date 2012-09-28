#!/usr/bin/perl
# script : ipa.translate.autofs.configuration.pl
# date   : 2012.09.28
# author : Yi Zhang
# version: 1.0
#
# license: GPL v2 please check COPYRIGHT.txt for details
#

use strict;
use warnings;


our %autofs;
our %autofsMap;
our $location="yztest001";

if ($#ARGV==0){
    $location = $ARGV[0];
}else{
    print "Usage: read.pl <ipa automount location name>\n";
    exit;
}
our $output=`ipa automountlocation-tofiles $location`;
parseAutofsFiles($output);
#printAutofsConf();
readAutofsMaster();
printAutofsMap();

print "\n";

############### subroutine #################

sub parseAutofsFiles{
    my ($output) = shift;
    $output="\n$output";
    my @lines=split(/\n/,$output);
    my $currentKey="";
    my $currentContent="";
    foreach my $line (@lines){
        $line =~ s/\n//;
        next if $line =~ /^\s*$/ ;
        next if $line =~ /maps not connected to/; # hard code is ok here
        $line = replaceSpecialChars($line);

        if ($line =~ /^\/etc\/auto.(\w+){1}:$/){
            $currentKey = "auto.$1";
        }elsif ($line =~ /^(-+)$/){
            $autofs{$currentKey} = $currentContent;
            $currentKey="";
            $currentContent="";
        }else{
            $currentContent = "$currentContent\n$line";
        }
    }
    # there is always exact one left over
    $autofs{$currentKey} = $currentContent;
}

sub readAutofsMaster{
    my $autoMaster = "auto.master";
    my $autoMasterContent = $autofs{$autoMaster};
    my @content = split (/\n/,$autoMasterContent);
    foreach my $configuration (@content){
        next if ( ($configuration =~ /^\s*$/) || ($configuration =~ /^#/) );
        my @map = split(/\s+/,$configuration);
        my $absolutePath = $map[0];
        my $configFile   = $map[1];
        if ($configFile =~ /^\/etc\/auto.(\w+){1}$/){
            my $key= "auto.$1";
            if (exists $autofs{$key}){
                my $value = $autofs{$key};
                next if ( ($value =~ /^\s*$/) || ($configuration =~ /^#/) );
                my @level2mapping = split(/\s/,$value);
                my $subPath = $level2mapping[1];
                my $remotePath = $level2mapping[$#level2mapping];
                my $localPath = $absolutePath. "/". $subPath;
                $autofsMap{$localPath} = $remotePath;
            }
        }
    }
}

sub printAutofsConf{
    foreach my $conf (keys %autofs){
        print "\n[$conf]    [".$autofs{$conf}."]";
    }
}

sub printAutofsMap{
    foreach my $local (keys %autofsMap){
        print "\n[$local]-->[".$autofsMap{$local}."]";
    }
}

sub printCharsInString{
    my ($string) = shift;
    my @chars = split(//,$string);
    foreach my $c (@chars){
        print "{$c (".ord($c).")} ";
    }
}

sub replaceSpecialChars{
    my $string = shift;
    my $header = substr($string,0,8);
    if ($header =~ /\[?1034h/){
        $string = substr($string,8);
    }
    return $string;
}
