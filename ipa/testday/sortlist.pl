#!/usr/bin/perl

use strict;
use warnings;


our $file;
our @lines;
our %list;
our $final="";
if ( $#ARGV != 0 ){
    exit;
}else{
    $file=$ARGV[0];
}

if (open DATA,"<$file"){
    #print "sort list from file: $file\n";
    @lines=<DATA>;
    close DATA;
}else{
    print "cannot read file\n";
    exit;
}

foreach my $line (@lines){
    chop $line;
    next if ($line =~ /^\s*$/); 
    #print "$line --> ";
    my @pair = split(/=/,$line);
    next if (! $#pair == 1);
    my $name=$pair[0];
    my $time=$pair[1];
    #print "$time : $name\n";
    if (exists $list{$time}){
        my $existing_name=$list{$time};
        $list{$time} = "$name $existing_name";
    }else{
        $list{$time}=$name;
    }
}

my @numbers = keys %list;
my @sorted_number = sort {$a <=> $b} @numbers;

foreach (@sorted_number){
    my $key = $_ . "";
    $final .= $list{$_}." ";
    #print "$_ :".$list{$_}."\n";
}

print "$final";
