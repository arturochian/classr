#' @title Create Directories for the Class

#' @description Creates submit, returned and mynotes directories in students' Home folders.
#' 
#' @rdname createDirectories
#' @usage createDirectories(studentfile=NULL,dom=NULL,key=NULL,passwordfile=NULL)
#' @param studentfile Text file containing student usernames, one per line.
#' @param dom the domain name
#' @param key Your key to decrypt your password
#' @param passwordfile File containing your encrypted password.
#' @return Side effects:  creation of directories.
#' @export
#' @author Scott Switzer and Homer White \email{hwhite0@@georgetowncollege.edu}
#' @examples
#' \dontrun{
#' createDirectories(studentfile="students.txt",dom="WORK",
#'      key="loveR",passwordfile="myLittleSecret.txt")
#' }
createDirectories <- function(studentfile=NULL,dom=NULL,key=NULL,passwordfile=NULL) {
  
  if (is.null(studentfile) | is.null(passwordfile) | is.null(key)) {
    stop("Must provide student file, your key and the password file.")
  }
  
  scriptPath <- system.file("perl","createdirectories.pl",package="classr")
  #scriptPath <- "inst/createdirectories.pl"
  comm <- paste0("perl ",scriptPath,
                 " --studentfile=",studentfile,
                 " --domainname=",dom,
                 " --key=",key,
                 " --passwordfile=",passwordfile)
  system(comm)
}
