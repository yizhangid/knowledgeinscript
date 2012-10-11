#!/usr/bin/perl
#
#

#BEGIN{ our $cur=`pwd`; push @INC,"$cur";}

use strict;
use warnings;
use Getopt::Std;
use Date::Parse;
require "certfunctions.pl";


our %options=();
getopts("d:n:p:f:s:", \%options);

our $certutil="/bin/certutil";
our $cert_dbdir;
our $cert_nickname;
our @cert_nicknamelist;
our %certs;
our $theCert;
our $status;
our $property_name;
our $property_value;
our $property_separator;
our $cert_outputfile;

# check -d user input
if (defined $options{"d"} ){
    $cert_dbdir = $options{"d"};
    if (! -d $cert_dbdir){
        print "Cert directory [$cert_dbdir] not exist\n";
        exit 1;
    }elsif (! -r $cert_dbdir){
        print "Cert directory [$cert_dbdir] not readable\n";
        exit 1;
    }
}else{
    print "Cert directory required, use -d <dir>\n";
    exit 1;
}

# check -n user input
findAllNickname();

if (defined $options{"n"} ){
    $cert_nickname= $options{"n"};
    if (! grep /$cert_nickname/, @cert_nicknamelist){
        print "Nickname [$cert_nickname] not found\n";
        printAllCertNickname();
        exit 1;
    }else{
        parseCertutil();
        if (defined $options{"s"} ){
            $status = $options{"s"};
            $theCert = findCert($cert_nickname,$status);
        }else{
            $theCert = findValidCert($cert_nickname);
        }
    }
}else{
    print "Cert nickname is required, use -n <nick name>\n";
    printAllCertNickname();
    exit 1;
}

if (defined $options{"p"} ){
    # print property value if -p is given, regardless of -f
    $property_name = $options{"p"};
    $property_value = "";
    if ($theCert){ 
        if (exists $theCert->{$property_name}){
            $property_value .= $theCert->{$property_name}. ",";
            chop $property_value;
            print "$property_value\n"; 
        }else{
            print "no such property: [$property_name]\n";
        }
    }else{
        print "no cert found\n";
    }
}else{
    if ($theCert){
        if (defined $options{"f"} ){
            $cert_outputfile= $options{"f"};
            printCertToFile($theCert, $cert_outputfile);
        }else{
            printCert($theCert);
        }
    }else{
        print "no cert found\n";
    }
}


