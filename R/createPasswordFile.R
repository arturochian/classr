#' @title Create the Password File

#' @description Creates a file conaining an encryption of your password.  The decyption is performed using a key
#' that you choose.  Clear your R history after using this function.
#' 
#' @rdname createPasswordFile
#' @usage createPasswordFile(password=NULL,file="myPasswordFile.txt",key=NULL)
#' @param password Your password, as a charater string.
#' @param file name of the file in which to store the encrypted password. 
#' Should reside in your Home directory.
#' @param key The key to be supplied to other functions to decrypt the password.
#' @return Only the side effect:  the password file.
#' @export
#' @author Scott Switzer and Homer White \email{hwhite0@@georgetowncollege.edu}
#' @examples
#' \dontrun{
#' createPasswordFile(password="yoyo68peewee",file="myLittleSecret.txt",key="loveR")
#' }
createPasswordFile <- function(password=NULL,file="myPasswordFile.txt",key=NULL) {
  
  if (is.null(password) | is.null(key)) stop("Must provide your password and a key.")
  
  scriptPath <- system.file("createpasswordfile.pl",package="classr")
  #scriptPath <- "inst/createpasswordfile.pl"
  comm <- paste0("perl ",scriptPath,
                 " --password=",password,
                 " --file=",file,
                 " --key=",key)
  system(comm)
  cat("\nYou should now clear your R History.\n")
}
