#!/usr/bin/perl
# functions called by other cert related perl program
sub trim{
    my $input = shift;
    $input =~ s/^([\t|\s])*//g;
    $input =~ s/([\t|\s])*$//g;
    return $input;
}

sub findAllNickname{
    my $cmdoutput = `$certutil -L -d $cert_dbdir`;
    my @lines = split(/\n/,$cmdoutput);
    foreach my $line (@lines){
        if ($line =~ /^(.*)\s+(\w*,\w*,\w*)$/){
            my $nickname=trim($1);
            #print "found nickname [$nickname]\n";
            push @cert_nicknamelist, $nickname;
        }
    }
}

sub printAllCertNickname{
    if ($#cert_nicknamelist >= 0){
        print "nicknames in $cert_dbdir\n";
        foreach (@cert_nicknamelist){
            print "$_\n";
        }
    }
}

sub parseCertDetails{
    my ($nickname, $certfile)= @_;
    open CERT,"<$certfile";
    my @lines = <CERT>;
    close CERT;
    my $flag=0;
    my $key=""; 
    my $value="";
    my %currentCert;
    foreach my $line (@lines){
        if ($line =~ /^Certificate:$/){
            if (%currentCert){
                $currentCert{"nickname"} = $nickname;
                my $serial = $currentCert{"serial"};
                my %copy = %currentCert;
                $certs{$serial} = \%copy;
            }
            next;
        }
        if ($line =~ /Serial Number:\s*(\d+)\s*/){
           $currentCert{"serial"} = trim($1); 
           next;
        }
        if ($line =~ /Issuer: "(.*)"/){
            $currentCert{"issuer"} = trim($1); 
            next;
        }
        if ($line =~ /Subject: "(.*)"/){
            $currentCert{"subject"} = trim($1); 
            next;
        }
        if ($line =~ /Not Before:(.*)$/){
            my $utcdate = trim($1);
            my $date=`date --date='$utcdate UTC'`;
            my $epoch = str2time($date);
            #my $d = localtime($time); # this is to convert it back to local time so I know this is epoch time
            $currentCert{"NotBefore_utc"}="$utcdate";
            $currentCert{"NotBefore"}="$date";
            $currentCert{"NotBefore_sec"}="$epoch";
            $currentCert{"Life"} = $epoch;
            next;
        }
        if ($line =~ /Not After :(.*)$/){
            my $utcdate = trim($1);
            my $date=`date --date='$utcdate UTC'`;
            my $epoch = str2time($date);
            $currentCert{"NotAfter_utc"}="$utcdate";
            $currentCert{"NotAfter"}="$date";
            $currentCert{"NotAfter_sec"}="$epoch";

            my $cert_life_insecond = $epoch - $currentCert{"Life"};
            my $cert_life_str = convert_time ($cert_life_insecond);
            $currentCert{"Life"} = $cert_life_str;
            $currentCert{"Life_sec"} = $cert_life_insecond;

            my $now = localtime;
            my $time_epoch_now = str2time($now);
            if ($time_epoch_now > $epoch){
                $currentCert{"status"} = "exipred";
            }else{
                $currentCert{"status"} = "valid";
            }

            my $time_left_str = convert_time($epoch - $time_epoch_now);
            $currentCert{"LifeLeft"} = $time_left_str;
            next;
        }
        if ($line =~ /Fingerprint \(SHA1\)/){
            $flag=1;
            $key = "Fingerprint SHA1";
            next;
        }
        if ($flag && $key ne "" ){
            $value = trim ($line);
            $currentCert{$key} = $value;
            $key="";
            $value="";
            $flag = 0;
            next;
        }
    }
    if (%currentCert){
        my $serial = $currentCert{"serial"};
        $currentCert{"nickname"} = $nickname;
        $certs{$serial} = \%currentCert;
    }
}


sub parseCertutil{
    my $cmdoutput = `$certutil -L -d $cert_dbdir -n "$cert_nickname"`;
    my @lines = split(/\n/,$cmdoutput);
    my $flag=0;
    my $key=""; 
    my $value="";
    my %currentCert;
    foreach my $line (@lines){
        if ($line =~ /^Certificate:$/){
            if (%currentCert){
                my $serial = $currentCert{"serial"};
                $currentCert{"certdb"} = $cert_dbdir;
                $currentCert{"nickname"} = $cert_nickname;
                my %copy = %currentCert;
                $certs{$serial} = \%copy;
            }
            next;
        }
        if ($line =~ /Serial Number:\s*(\d+)\s*/){
           $currentCert{"serial"} = trim($1); 
           next;
        }
        if ($line =~ /Issuer: "(.*)"/){
            $currentCert{"issuer"} = trim($1); 
            next;
        }
        if ($line =~ /Subject: "(.*)"/){
            $currentCert{"subject"} = trim($1); 
            next;
        }
        if ($line =~ /Not Before:(.*)$/){
            #my $date = trim($1);
            my $utcdate = trim($1);
            my $date=`date --date='$utcdate UTC'`;
            #my $epoch = str2time($date." UTC");
            my $epoch = str2time($date);
            #my $d = localtime($time); # this is to convert it back to local time so I know this is epoch time
            $currentCert{"NotBefore"}="$date";
            $currentCert{"NotBefore_utc"}="$utcdate UTC";
            $currentCert{"NotBefore_sec"}="$epoch";
            $currentCert{"Life"} = $epoch;
            next;
        }
        if ($line =~ /Not After :(.*)$/){
            #my $date = trim($1);
            my $utcdate = trim($1);
            my $date=`date --date='$utcdate UTC'`;
            my $epoch = str2time($date) + 0;
            $currentCert{"NotAfter"}="$date";
            $currentCert{"NotAfter_utc"}="$utcdate UTC";
            $currentCert{"NotAfter_sec"}="$epoch";

            my $cert_life_insecond = $epoch - $currentCert{"Life"};
            my $cert_life_str = convert_time ($cert_life_insecond);
            $currentCert{"Life"} = $cert_life_str;
            $currentCert{"Life_sec"} = $cert_life_insecond;

            next;
        }
        if ($line =~ /Fingerprint \(SHA1\)/){
            $flag=1;
            $key = "Fingerprint SHA1";
            next;
        }
        if ($flag && $key ne "" ){
            $value = trim ($line);
            $currentCert{$key} = $value;
            $key="";
            $value="";
            $flag = 0;
            next;
        }
    }
    if (%currentCert){
        my $serial = $currentCert{"serial"};
        $currentCert{"certdb"} = $cert_dbdir;
        $currentCert{"nickname"} = $cert_nickname;
        $certs{$serial} = \%currentCert;
    }
}

sub printCert{
    my ($cert) = shift;
    if (ref($cert) eq "HASH"){
        foreach (sort keys %$cert){
            my $key = $_;
            $key = sprintf ("%-18s",$key);
            print "$key: ".$cert->{$_}."\n";
        }
    }}

sub printAllCerts{
    if (%certs){
        foreach (sort keys %certs){
            print "cert# ($_)\n";
            my $cert= $certs{$_};
            printCert($cert);
        }
    }
}

sub convert_time { 
    # this function is from: http://neilang.com/entries/converting-seconds-into-a-readable-format-in-perl/
    # my change: add years
    my $time = shift; 
    my $prefix="";
    my $suffix="";
    if ($time < 0){
        $prefix="Expired ";
        $suffix=" ago";
        $time = abs($time);
    }
    #my $years = int($time / (86400*365) ); 
    #$time -= ($years * 86400 * 365); 
    my $days = int($time / 86400); 
    $time -= ($days * 86400); 
    my $hours = int($time / 3600); 
    $time -= ($hours * 3600); 
    my $minutes = int($time / 60); 
    my $seconds = $time % 60; 
  
    #$years = $years < 1 ? '' : $years .' Y '; 
    $days = $days < 1 ? '' : $days .' D '; 
    $hours = $hours < 1 ? '' : $hours .' h '; 
    $minutes = $minutes < 1 ? '' : $minutes . ' m '; 
    #$time = $prefix.$years. $days . $hours . $minutes . $seconds . ' s'. $suffix; 
    $time = $prefix.$days.$hours.$minutes.$seconds.' s'.$suffix; 
    return $time; 
}

sub findCert{
    my ($nickname,$status)=@_;
    #print "debug: find [$nickname],[$status]\n";
    if (%certs){
        foreach (sort keys %certs){
            my $cert = $certs{$_};
            setCertStatus($cert);
            if ($cert->{"nickname"} eq $nickname
               && $cert->{"status"} eq $status ){
                setCertLifeLeft($cert);
                return $cert;
            }else{
                #print "debug: read cert [".$cert->{"nickname"}."], [".$cert->{"status"}."]\n";
            }
        }
    }
}

sub findPreValidCert{
    my $nickname=shift;
    my $status="preValid";
    return findCert($nickname,$status);
}

sub findValidCert{
    my $nickname=shift;
    my $status="valid";
    return findCert($nickname,$status);
}

sub findExpiredCert{
    my $nickname=shift;
    my $status="expired";
    return findCert($nickname,$status);
}

sub printCertToFile{
    my ($cert, $output) = @_;
    if (ref($cert) eq "HASH"){
        if (! open OUT, ">$output"){
            return;
        }
        foreach (sort keys $cert){
            my $key = $_;
            my $formatted_key = sprintf("%-16s",$key);
            print OUT $formatted_key."| ".$cert->{$_}."\n";
        }
        close OUT;
    }
}

sub setCertLifeLeft{
    my $cert=shift;
    my $now = localtime;
    my $time_epoch_now = str2time($now);
    my $notafter=$cert->{"NotAfter_sec"}+0;
    my $time_left = $notafter - $time_epoch_now;
    my $time_left_str = convert_time($time_left);
    $cert->{"LifeLeft_sec"} = $time_left;
    $cert->{"LifeLeft"} = $time_left_str;
}

sub setCertStatus{
    my $cert=shift;
    my $now = localtime;
    my $time_epoch_now = str2time($now);
    my $notbefore=$cert->{"NotBefore_sec"}+0;
    my $notafter=$cert->{"NotAfter_sec"}+0;
    if ($time_epoch_now < $notbefore){
        $cert->{"status"} = "preValid";
    }elsif ($notbefore <= $time_epoch_now && $time_epoch_now <= $notafter){
        $cert->{"status"} = "valid";
    }else{ 
        $cert->{"status"} = "expired";
    }  
    #print "debug: set cert [".$cert->{"nickname"}."] status to:(".$cert->{"status"}.")\n";
}

sub isValid{
    my $cert=shift;
    if (! exists $cert->{"status"}){
        setCertStatus($cert);
    }
    if ($cert->{"status"} eq "valid" ){
        return 1;
    }else{
        return 0;
    }
}

sub LDAPsearch{
    my ($ldap,$searchString,$attrs,$base) = @_;
    if (!$attrs ) { 
        $attrs = [ 'cn','userCertificate' ]; 
    }

    my $result = $ldap->search ( 
                    base    => "$base",
                    scope   => "sub",
                    filter  => "$searchString",
                    attrs   =>  $attrs
                    );
    my $href = $result->as_struct;
    my @arrayOfDNs  = keys %$href;        # use DN hashes
    foreach ( @arrayOfDNs ) {
        next if ( $_ =~ /^cn=ca_renewal/ );
        print "found renewal cert DN [$_] \n";
        my $valref = $$href{$_};
        my @arrayOfAttrs = sort keys %$valref; #use Attr hashes
        my $attrName;        
        my $nickname;
        foreach $attrName (@arrayOfAttrs) {
            next if ( $attrName =~ /;binary$/ );
            my $attrVal =  @$valref{$attrName};
            if ($attrName =~ /cn/i){
                $nickname = @$attrVal[0];
            }
            if ($attrName =~ /userCertificate/i){
                my $derfile="/tmp/cert.".rand().".der";
                my $certfile="$derfile".".cert";
                if (saveAsFile($certfile,$derfile, @$attrVal)){
                    #print "\t $attrName: der file: [$derfile], cert file [$certfile]\n";
                    parseCertDetails($nickname, $certfile);
                }
            }else{
                #print "\t $attrName: @$attrVal \n";
            }
        }
        #print "#-------------------------------\n";
    }
}

sub saveAsFile{
    my ($certfile,$derfile,@content) = @_;
    if (open PKCS12,">$derfile"){
        foreach (@content){
            print PKCS12 $_;
        }
        close PKCS12; 
        my $certDetail=`openssl x509 -inform der -in $derfile -text > $certfile`;
        return 1;
    }else{
        print "can not open file [$derfile] to write\n";
        return 0;
    } 
}
1;
