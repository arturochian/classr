#!/usr/bin/perl -w

use strict;
use File::Find;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home";

#*********************************************************************************************


#collect commandline arguments



sub showUsage {

print "\nUSAGE: perl collecthomework.pl --instructor=<name> --assignment=<name> --domainname=<domain> --studentfile=<filename> \n Optional Parameters:\n\n[--source=<source path> (Alternate source path)\n--destination=<destination path> (Alternate destination path)\n --remove (Remove homework files after copying them)\n --email=<email address> (Email for submission report)]\n\n";
exit;

}


my($instructor,$assignment,$studentfile,$destinationRoot,$sendEmail,$recipientAddress,$domainname);

$sendEmail = FALSE;

foreach my $item(@ARGV) {

  if ($item =~ m/--instructor=/i) {
		$instructor = substr($item,13,length($item)-13);
	}


 	if ($item =~ m/--assignment=/i) {
                $assignment = substr($item,13,length($item)-13);
        }

  if ($item =~ m/--domainname=/i) {
    $domainname = substr($item,13,length($item)-13); 
  }


	if ($item =~ m/--studentfile=/i) {
                $studentfile = substr($item,14,length($item)-14);
        }

 	if ($item =~ m/--source=/i) {
		 $sourceRoot = substr($item,9,length($item)-9);                
        }

	if ($item =~ m/--destination=/i) {
                 $destinationRoot = substr($item,14,length($item)-14);
        }

	if ($item =~ m/--email=/i) {
                $sendEmail = TRUE;
		$recipientAddress = substr($item,8,length($item)-8);
        }



}


if (!$instructor || !$assignment || !$studentfile || !$domainname) {
&showUsage;
}


if (!$destinationRoot) {
	$destinationRoot = $sourceRoot . "/" . $domainname . "/" . $instructor . "/homework";
}


my($noSubmissionYet) = "\nThe following students have not submitted homework yet:\n------------------------------------------------------------";
my($summaryLine) = "\nHomework assignments retrieved for assignment $assignment:\n-------------------------------------";


my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {

 	$_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
        my($inputLine) = $_;
        chomp ($inputLine);

        unless ($inputLine =~ /^\s*$/) {





        my(@searchFolders) = ($sourceRoot . "/" . $domainname . "/" . $inputLine . "/submit");
	my(@foundProjects);

        find( sub { push @foundProjects, $File::Find::name if /$assignment/i }, @searchFolders);

	
        my($projectFile);

        foreach $projectFile(@foundProjects) {

		print "\nFound $projectFile.";

                my ($destinationFolder) = $destinationRoot . "/" . $assignment . "/" . $inputLine;
                unless (-e $destinationFolder) {
                        system ("mkdir -p $destinationFolder");
                }

                $destinationFolder = $destinationFolder . "/";
                system ("cp -f $projectFile $destinationFolder");
		$summaryLine = $summaryLine . "\n $inputLine submitted file: $projectFile";		

	}

	if (!@foundProjects) {
		$noSubmissionYet = $noSubmissionYet . "\n$inputLine";
	}


	}

}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n\n" . $noSubmissionYet . "\n\n";

print $summaryLine;

if ($sendEmail == TRUE) {
	print "\nSending summary email to $recipientAddress.\n";
	my ($emailSubject) = "Subject: RStudio projects submitted for assignment $assignment";
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