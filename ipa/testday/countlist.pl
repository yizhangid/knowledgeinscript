#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use Date::Parse;


our %options=();
getopts("s:c:", \%options);

our $sourceStr;
our $item;

our @source;
our %counter;

if (defined $options{"s"} ){
    $sourceStr=$options{"s"};
    @source=split(/ /,$sourceStr);
}else{
    print "no source string defined -s <spaces separated string>\n";
    exit 1;
}

if (defined $options{"c"} ){
    $item=$options{"c"};
}else{
    print "no item string defined -c <string>\n";
    exit 1;
}

foreach (@source){
    if (exists $counter{$_} ){
        my $index = $counter{$_};
        $counter{$_} = $index + 1;
    }else{
        $counter{$_} = 1;
    }
}

if (exists $counter{"$item"}){
    print $counter{"$item"};
}else{
    print 0;
}

#print "source : [$sourceStr]\n";
#print "records: [$recordsStr]\n";
