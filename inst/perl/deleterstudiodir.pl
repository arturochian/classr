#!/usr/bin/perl -w

use strict;
use Crypt::RC4;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home";
my($group) = "admins";
my($permissions) = "770";

#*********************************************************************************************


# deleterstudiodir commandline arguments



sub showUsage {

print "\nUSAGE: perl deleterstudiodir.pl --domainname=<domain> --user=<name> --key=<password file key> --passwordfile=<password file>]\n\n";
exit;

}


my($key,$passwordFile,$decryptedPassword,$domainname,$user,$target);


foreach my $item(@ARGV) {


  if ($item =~ m/--domainname=/i) {
    $domainname = substr($item,13,length($item)-13);
        }


	if ($item =~ m/--key=/i) {
                $key = substr($item,6,length($item)-6);
        }

	if ($item =~ m/--passwordfile=/i) {
                $passwordFile = substr($item,15,length($item)-15);
        }

  if ($item =~ m/--user=/i) {
                $user = substr($item,7,length($item)-7);
        }

}


if ($passwordFile) {

	my($INPUTFILE);
	open ($INPUTFILE, "<$passwordFile") or die "Could not open $passwordFile\n";

	while (<$INPUTFILE>) {
        	my($inputLine) = $_;
        	chomp ($inputLine);

		$decryptedPassword = RC4($key,$inputLine);
	}
	
}


$target = $sourceRoot . "/" . $domainname . "/" . $user . "/.rstudio";

system ("echo $decryptedPassword | sudo rm -rf $target");

print "If there were no error messages, then the .rstudio folder of user " . $user . " was deleted.\n\nMay God have mercy on your soul.\n";
