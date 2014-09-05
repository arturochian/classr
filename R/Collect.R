#' @title Collect an Assignment from the Class

#' @description Makes a copy of the ungraded assignment the student's submit folder and places it
#' in a subdirectory of your homework folder.
#' 
#' @rdname Collect
#' @usage Collect(studentfile=NULL,dom=NULL,inst=NULL,assign=NULL,email=NULL)
#' @param studentfile Text file containing student usernames, one per line.
#' @param dom the domain name
#' @param inst instructor's username
#' @param assign code for the assignment to be collected
#' @param email Receive an email confirming results?
#' @return Side effects: graded copy returned to student, with permissions set so student can
#' open it.
#' @export
#' @author Scott Switzer and Homer White \email{hwhite0@@georgetowncollege.edu}
#' @examples
#' \dontrun{
#' Collect(studentfile="students.txt",dom="WORK", inst="jdoe1",assign="HW01")
#' }
Collect <- function(studentfile=NULL,dom=NULL,inst=NULL,assign=NULL,email=NULL) {
  
  if (is.null(studentfile) | is.null(dom) | is.null(assign) | is.null(inst)) {
    stop("Must provide student file, domain name, instructor username and the assignment code.")
  }
  
  scriptPath <- system.file("collecthomework.pl",package="classr")
  #scriptPath <- "inst/collecthomework.pl"
  comm <- paste0("perl ",scriptPath,
                 " --studentfile=",studentfile,
                 " --domainname=",dom,
                 " --instructor=",inst,
                 " --assignment=",assign,
                 " --email=",email)
  system(comm)
}
