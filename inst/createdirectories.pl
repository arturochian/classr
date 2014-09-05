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


#createdirectories commandline arguments



sub showUsage {
  
  print "\nUSAGE: perl createdirectories.pl --studentfile=<filename> [--source=<source path> (Alternate source path) --domainname=<domain> --email=<email address> (Email for submission report) --group=<group name> (Security Group) --permissions=<nnn> (Default Directory Permissions) --key=<password file key> --passwordfile=<password file>]\n\n";
  exit;
  
}


my($studentfile,$sendEmail,$summaryLine,$recipientAddress,$key,$passwordFile,$decryptedPassword,$domainname,$userDirective);

$sendEmail = FALSE;

foreach my $item(@ARGV) {
  
  
  if ($item =~ m/--studentfile=/i) {
    $studentfile = substr($item,14,length($item)-14);
  }
  
  if ($item =~ m/--source=/i) {
    $sourceRoot = substr($item,9,length($item)-9);
  }
  
  if ($item =~ m/--email=/i) {
    $sendEmail = TRUE;
    $recipientAddress = substr($item,8,length($item)-8);
  }
  
  if ($item =~ m/--group=/i) {
    $group = substr($item,8,length($item)-8);
  }
  
  if ($item =~ m/--permissions=/i) {
    $permissions = substr($item,14,length($item)-14);
  }

  if ($item =~ m/--domainname=/i) {
    $domainname = substr($item,13,length($item)-13);
    $userDirective = $domainname; 
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



if (!$studentfile) {
  &showUsage;
}




$summaryLine = "\nDirectory Permission Updates:\n--------------------------\n\n";



my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {
  
  $_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
  my($inputLine) = $_;
  chomp ($inputLine);
  
  unless ($inputLine =~ /^\s*$/) {
    
    
    my($submitPath) = $sourceRoot . "/" . $domainname . "/" . $inputLine . "/submit";
    my($returnPath) = $sourceRoot . "/" . $domainname . "/" . $inputLine . "/returned";
    my($mynotesPath) = $sourceRoot . "/" . $domainname . "/" . $inputLine ."/mynotes";
    
    unless (-e $submitPath) { 
      system ("echo $decryptedPassword | sudo mkdir $submitPath"); #or die "\nCould not create directory $submitPath.\n"; 
      $summaryLine = $summaryLine . "\nCreated submit path $submitPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nSubmit path $submitPath for user $inputLine already exists.\n";
    }
    
    unless (-e $returnPath) { 
      system ("echo $decryptedPassword | sudo mkdir $returnPath");  #or die "\nCould not create directory $returnPath.\n"; 
      $summaryLine = $summaryLine . "\nCreated return path $returnPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nReturn path $returnPath for user $inputLine already exists.\n";
    }
    
    unless (-e $mynotesPath) {
      system ("echo $decryptedPassword | sudo mkdir $mynotesPath");  #or die "\nCould not create directory $returnPath.\n";
      $summaryLine = $summaryLine . "\nCreated mynotes path $mynotesPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nmynotes path $mynotesPath for user $inputLine already exists.\n";
    }
    
    
    my($securityToken) = $userDirective . $inputLine . ":" . $group;
    
    system("echo $decryptedPassword | sudo chown $securityToken $submitPath");
    $summaryLine = $summaryLine . "\nChanged ownership of submit path $submitPath to $securityToken.\n";
    
    system("echo $decryptedPassword | sudo chown $securityToken $returnPath");
    $summaryLine = $summaryLine . "\nChanged ownership of return path $returnPath to $securityToken.\n";
    
    system("echo $decryptedPassword | sudo chown $securityToken $mynotesPath");
    $summaryLine = $summaryLine . "\nChanged ownership of mynotes path $mynotesPath to $securityToken.\n";
    
    
    system("echo $decryptedPassword | sudo chmod $permissions $submitPath");
    $summaryLine = $summaryLine . "\nChanged permissions of submit path $submitPath to $permissions.\n";
    
    system("echo $decryptedPassword | sudo chmod $permissions $returnPath");
    $summaryLine = $summaryLine . "\nChanged permissions of return path $returnPath to $permissions.\n";
    
    system("echo $decryptedPassword | sudo chmod $permissions $mynotesPath");
    $summaryLine = $summaryLine . "\nChanged permissions of mynotes path $mynotesPath to $permissions.\n";
    
    
  }
  
}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n";

print $summaryLine;

if ($sendEmail == TRUE) {
  print "\nSending summary email to $recipientAddress.\n";
  my ($emailSubject) = "Subject: RStudio directories updated";
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