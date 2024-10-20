# Bash example
# valgrind --leak-check=full Rscript -e "library(ece244); squared_sum_iso_(1:5)"
# R --vanilla -d 'valgrind -s --leak-check=full --show-leak-kinds=all --track-origins=yes' -f test.R

#' @title Test memory leaks with 'valgrind'
#' @description Installs an R package and runs the tests or a custom script in a
#'  separate R session in vanilla mode.
#' @param pkg_dir A character string with the name of the package to install.
#' @param script A character string with the path to the script to run.
#' @param leak_check When enabled, search for memory leaks when the client
#'  program finishes. The options are "no", "summary", "yes", and "full". The
#'  default is "summary".
#' @param leak_resolution When doing leak checking, determines how willing
#'  'Memcheck' is to consider different backtraces to be the same for the
#'  purposes of merging multiple leaks into a single leak report. The options
#'  are "low", "med", and "high". The default is "med".
#' @param show_leak_kinds Specifies the leak kinds to show in a full leak
#'  search. The options are "definite", "indirect", "possible", "reachable",
#'  and these can be combined with a comma. The default is "definite,possible".
#' @param errors_for_leak_kinds Specifies the leak kinds to count as errors in a
#'  full leak search. The options are the same as 'show_leak_kinds'. The default
#'  is "definite,possible".
#' @param leak_check_heuristics Specifies the set of leak check heuristics to be
#'  used during leak searches. The options are "all", "stdstring", "length64",
#'  "newarray", "multipleinheritance", and these can be combined with a comma.
#'  The default is "all".
#' @param track_origins Controls whether 'Memcheck' tracks the origin of
#'  uninitialised values. The options are "yes" and "no". The default is "no".
#' @return A list with the results of the test.
#' @export
#' @examples
#' # This cannot be run from R CMD check
#' \dontrun{
#' dummy_file <- tempfile(fileext = ".R")
#' writeLines(c("a_plus_b(1, 2)"), dummy_file)
#' test_memory(".", dummy_file)
#' }
#'
#' # see src/code.cpp for the implementation of intentional_leak
#' # dummy_file <- tempfile(fileext = ".R")
#' # writeLines(c("intentional_leak(1, 2)"), dummy_file)
#' # test_memory(".", dummy_file, leak_check = "full")
test_memory <- function(pkg_dir,
                        script,
                        leak_check = "summary",
                        leak_resolution = "med",
                        show_leak_kinds = "definite,possible",
                        errors_for_leak_kinds = "definite,possible",
                        leak_check_heuristics = "all",
                        track_origins = "no") {
  # Install the package ----
  pkg_name <- read.dcf(file.path(pkg_dir, "DESCRIPTION"))
  pkg_name <- pkg_name[1, "Package"]
  # message("Installing package ", pkg_name)
  install.packages(pkg_dir, repos = NULL, type = "source", quiet = TRUE)

  # Alter the script to load the package ----

  script <- readLines(script)
  script <- c(
    sprintf("library(%s)", pkg_name),
    "\n",
    script
  )

  # Write to a temporary file ----
  tempscript <- tempfile(fileext = ".R")
  writeLines(script, con = tempscript)

  # Run the script ----
  tempout <- tempfile(fileext = ".txt")

  system2("R", c(
    "--vanilla -d",
    sprintf(
      "'valgrind -s
    --leak-check=%s
    --show-leak-kinds=%s
    --errors-for-leak-kinds=%s
    --leak-resolution=%s
    --leak-check-heuristics=%s
    --track-origins=%s'",
      leak_check, show_leak_kinds, errors_for_leak_kinds, leak_resolution,
      leak_check_heuristics, track_origins
    ),
    "-f", tempscript
  ), stdout = tempout, stderr = tempout)

  # Return the results ----
  tidy_output <- readLines(tempout)
  unlink(tempscript)
  unlink(tempout)

  # start from HEAP SUMMARY
  start <- grep("HEAP SUMMARY", tidy_output)
  end <- grep("ERROR SUMMARY", tidy_output)
  tidy_output <- tidy_output[start:end]

  # remove the ==68257== insertions
  tidy_output <- gsub("==[0-9]+==\\s+", "", tidy_output)

  # put HEAP SUMMARY in a list
  tidy_list <- list()
  current_section <- NULL
  current_lines <- c()

  for (line in tidy_output) {
    if (line == "HEAP SUMMARY:") {
      if (!is.null(current_section)) {
        tidy_list[[current_section]] <- current_lines
      }
      current_section <- "HEAP SUMMARY"
      current_lines <- c()
    } else if (line == "LEAK SUMMARY:") {
      if (!is.null(current_section)) {
        tidy_list[[current_section]] <- current_lines
      }
      current_section <- "LEAK SUMMARY"
      current_lines <- c()
    } else if (startsWith(line, "ERROR SUMMARY:")) {
      if (!is.null(current_section)) {
        tidy_list[[current_section]] <- current_lines
      }
      current_section <- "ERROR SUMMARY"
      current_lines <- c(line)
    } else {
      current_lines <- c(current_lines, line)
    }
  }

  if (!is.null(current_section)) {
    tidy_list[[current_section]] <- current_lines
  }

  names(tidy_list) <- tolower(gsub(" ", "_", names(tidy_list)))

  for (name in names(tidy_list)) {
    tidy_list[[name]] <- tidy_list[[name]][tidy_list[[name]] != ""]
  }

  return(tidy_list)
}
