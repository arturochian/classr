#' @title Delete a User's .rstudio Folder

#' @description Used to delte the .rsudio folder of a user whose problems 
#' cannot be addressed by less drastic measures.
#' 
#' @rdname DropBomb
#' @usage DropBomb(dom=NULL,user=NULL,key=NULL,passwordfile=NULL)
#' @param dom the domain name
#' @param user user's username
#' @param key Your key to decrypt your password
#' @param passwordfile File containing your encrypted password.
#' @return Side effects:  the targeted user has no .rstudio folder, until he/she logs on again.
#' @export
#' @author Homer White \email{hwhite0@@georgetowncollege.edu}
#' @examples
#' \dontrun{
#' DropBomb(dom="WORK", user="jdoe1",assign="HW01",key="loveR",
#'       passwordfile="myLittleSecret.txt")
#' }
DropBomb <- function(dom=NULL,user=NULL,key=NULL,passwordfile=NULL) {
  
  if (is.null(user) | is.null(dom) | is.null(passwordfile) | is.null(key) ) {
    stop("Must provide domain name, username of targeted user, your key and the password file.")
  }
  
  question <- paste0("Are you sure you want to delete the .rstudio folder of ",user,"? (y/n)")
  confirmed <- readline(question)
  
  if (confirmed=="y") {
    scriptPath <- system.file("deleterstudiodir.pl",package="classr")
    comm <- paste0("perl ", scriptPath,
                 " --domainname=",dom,
                 " --user=",user,
                 " --key=",key,
                 " --passwordfile=",passwordfile)
    system(comm)
  } else cat("OK, I'll back off.\n")
  
}
