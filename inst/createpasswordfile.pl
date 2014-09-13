#!/usr/bin/perl -w

use strict;
use Crypt::RC4;


my($clearText,$passwordFile,$key);

foreach my $item(@ARGV) {

        if ($item =~ m/--password=/i) {
                $clearText = substr($item,11,length($item)-11);
        }


        if ($item =~ m/--file=/i) {
                $passwordFile = substr($item,7,length($item)-7);
        }


        if ($item =~ m/--key=/i) {
                $key = substr($item,6,length($item)-6);
        }


}


if (!$passwordFile || !$clearText || !$key) {
print "\n USAGE: perl createpasswordfile.pl --password=<domain password> --key=<password file key> --file=<secure password file>\n\n";
exit;
}

my($encryptedPassword) = RC4($key,$clearText);

my($OUTPUTFILE);
open ($OUTPUTFILE, ">$passwordFile") or die "Could not open $passwordFile.  Delete it if it already exists, then try again!\n";
print $OUTPUTFILE "$encryptedPassword";
close ($OUTPUTFILE);

system("chmod 400 $passwordFile");

print "\n\nPassword file $passwordFile written.\n";