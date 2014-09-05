#!/usr/bin/perl -w

use strict;
use File::Find;
use Crypt::RC4;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home";
my($group) = "admins";
my($permissions) = "770";

#*********************************************************************************************


#return commandline arguments



sub showUsage {

print "\nUSAGE: perl returnhomework.pl --path=<name> --flag=<name> --studentfile=<filename> \n --domainname=<domain> Optional Parameters:\n\n[--email=<email address> (Email for submission report) --key=<password file key> --passwordfile=<password file>]\n\n";
exit;

}


my($path,$flag,$studentfile,$destinationRoot,$sendEmail,$recipientAddress,$key,$passwordFile,$decryptedPassword,$userDirective,$domainname);

$sendEmail = FALSE;


foreach my $item(@ARGV) {



   if ($item =~ m/--flag=/i) {
                $flag = substr($item,7,length($item)-7);
        }


	if ($item =~ m/--studentfile=/i) {
                $studentfile = substr($item,14,length($item)-14);
        }

  if ($item =~ m/--domainname=/i) {
    $domainname = substr($item,13,length($item)-13);
    $userDirective = $domainname;
        }

 	if ($item =~ m/--path=/i) {
		 $path = substr($item,7,length($item)-7);                
        }

	if ($item =~ m/--destination=/i) {
                 $destinationRoot = substr($item,14,length($item)-14);
        }

	if ($item =~ m/--email=/i) {
                $sendEmail = TRUE;
		$recipientAddress = substr($item,8,length($item)-8);
        }


	if ($item =~ m/--key=/i) {
                $key = substr($item,6,length($item)-6);
        }

	if ($item =~ m/--passwordfile=/i) {
                $passwordFile = substr($item,15,length($item)-15);
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


if (!$path || !$flag || !$studentfile) {
&showUsage;
}


unless ( $path =~ s|/\s*$|/| ) 
{
    $path = $path . "/";
}


if (!$destinationRoot) {
	$destinationRoot = $sourceRoot . "/" . $domainname . "/";
}

my($summaryLine) = "\nHomework graded in folder $path:\n-------------------------------------";


my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {

 	$_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
        my($inputLine) = $_;
        chomp ($inputLine);

        unless ($inputLine =~ /^\s*$/) {



        my(@searchFolders) = ($path .  $inputLine);
	my(@foundProjects);

        find( sub { push @foundProjects, $File::Find::name if /$flag/i }, @searchFolders);

	
        my($projectFile);

        foreach $projectFile(@foundProjects) {

		print "\nFound $projectFile.";

                my ($destinationFolder) = $destinationRoot . $inputLine . "/returned";
                unless (-e $destinationFolder) {
                        system ("mkdir -p $destinationFolder");
                }

                $destinationFolder = $destinationFolder . "/";

 		my($securityToken) = $userDirective . "\\\\" . $inputLine . ":" . $group;
        	
                system ("cp -f $projectFile $destinationFolder");
		
		my($folderWildcard) = $destinationFolder . "*";
	

		if ($passwordFile) {
                	system("echo $decryptedPassword | sudo chown $securityToken $folderWildcard");
                	system ("echo $decryptedPassword | sudo chmod 770 $folderWildcard");
		} else {
			system("chown $securityToken $folderWildcard");
                	system("chmod 770 $folderWildcard");
		}

		
		$summaryLine = $summaryLine . "\n $inputLine returned $projectFile to $destinationFolder\n";		


	}


	}

}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n";

print $summaryLine;

if ($sendEmail == TRUE) {
	print "\nSending summary email to $recipientAddress.\n";
	my ($emailSubject) = "Subject: RStudio projects graded and returned.";
	my ($sendmailObject) = "/usr/sbin/sendmail -F RStudio_Grades\@georgetowncollege.edu -t";
	my ($replyAddress) = "Reply-to: RStudio_Grades\@georgetowncollege.edu";
	my ($recipient) = "To: $recipientAddress";
	open (SENDMAIL, "|$sendmailObject") or die "Cannot open $sendmailObject: $!";
	print SENDMAIL $emailSubject;
	print SENDMAIL "\n";
	print SENDMAIL $recipient;
	print SENDMAIL "\n";
	print SENDMAIL $replyAddress;
	print SENDMAIL "\n";
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL "\n";
	print SENDMAIL $summaryLine;
	print SENDMAIL "\n";
	print SENDMAIL ".";
	close (SENDMAIL);


}