Script to run:
* testday.autorenewcert.sh

Before use this script:
1. please modify the hard-coded test data in script testday.autorenewcert.sh as below:
    * ROOTDNPW ADMINPW 
    without the password for IPA admin account and "cn=directory manager" account, test won't report correct test result

2. please ensure "expect" pkg is installed

Other things:
* You have to run this script as "root"
* all required tools, such as countlist.pl ... should be in same directory
* this script has been tested under Fedora 17. As of this readme.txt is writing, some certs are get renewed at first round, but some certs failed to auto-renew.

Logic:
* the man logic is inside this function: main_autorenewcert_test
* logic flow:
    * check current certs date
    * adjust system to certs expiration date - 6 days
    * check certs renewal
    * adjust system to post-expiration date
    * check ipa server functions
    * repeat above steps till all certs get chance to renew at lease once

please send me email if things does not work : yizhangid @ gmail com
