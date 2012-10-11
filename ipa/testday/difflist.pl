#!/usr/bin/perl
#

use strict;
use warnings;


our @listA;
our $stringA;
our @listB;
our $stringB;
our @diff;
if ( $#ARGV != 1 ){
    exit;
}else{
    $stringA=$ARGV[0];
    @listA = split(/ /,$stringA);
    $stringB=$ARGV[1];
    @listB = split(/ /,$stringB);
}

foreach (@listA){
    my $str=$_;
    if ($stringB =~ /$str/){
        
    }else{
        push @diff, $str ;
    }
}

foreach (@listB){
    my $str=$_;
    if ($stringA =~ /$str/){

    }else{
        push @diff, $str ;
    }
}

print "@diff\n";
