#' @title Return an Assignment to the Class

#' @description Picks the graded, commented copy of the assignment from the student's folder in your
#' homework directory and places it the student's returned directory.
#' 
#' @rdname Return
#' @usage Return(studentfile=NULL,dom=NULL,assign=NULL,key=NULL,passwordfile=NULL,flag="_com",email=NULL)
#' @param studentfile Text file containing student usernames, one per line.
#' @param dom the domain name
#' @param assign code for the assignment to be returned
#' @param key Your key to decrypt your password
#' @param passwordfile File containing your encrypted password.
#' @param flag the tag at the end of the file-name that identifies the copy with your comments.
#' @param email Receive an email confirming results?
#' @return Side effects: graded copy returned to student, with permissions set so student can
#' open it.
#' @export
#' @author Scott Switzer and Homer White \email{hwhite0@@georgetowncollege.edu}
#' @examples
#' \dontrun{
#' Return(studentfile="students.txt",dom="WORK", assign="HW01",
#'      key="loveR",passwordfile="myLittleSecret.txt",flag="_com")
#' }
Return <- function(studentfile=NULL,dom=NULL,assign=NULL,key=NULL,passwordfile=NULL,flag="_com", email=NULL) {
  
  if (is.null(studentfile) | is.null(dom) | is.null(passwordfile) | is.null(key) | is.null(assign)) {
    stop("Must provide student file, domain name, assignment, your key and the password file.")
  }
  
  scriptPath <- system.file("returnhomework.pl",package="classr")
  #scriptPath <- "inst/returnhomework.pl"
  comm <- paste0("perl ",scriptPath,
                 " --studentfile=",studentfile,
                 " --domainname=",dom,
                 " --path=",assign,
                 " --key=",key,
                 " --passwordfile=",passwordfile,
                 " --flag=",flag,
                 " --email=",email)
  system(comm)
}
