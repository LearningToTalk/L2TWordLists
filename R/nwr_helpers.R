
#' Convenience function to create a WordList given a ResearchID, study and
#' folder
#'
#' @param short_id four-character short participant ID (e.g., "001L"). Use `""`
#'   for a wildcard search that will match all 4-character participants IDs.
#' @param study_name name of an L2T study (e.g., "TimePoint1")
#' @param dir_task the fully specified filepath to the folder for a Task. The
#'   value for `study_name` should be a subfolder in this location.
#' @param dir_eprime folder that contains Eprime output files. Defaults to
#'   `"Recordings"`.
#' @param dir_wordlist folder where the WordList should be saved. Defaults to
#'   `"WordLists"`.
#' @param read_only whether to protect the saved WordList. Defaults to `TRUE`.
#' @param update whether to update the saved WordList. Defaults to `FALSE`.
#' @return a list of the file-paths of the generated WordList files and the
#'   contents of the WordLists files (as data-frames).
#' @export
#' @rdname create_wordlists
create_nwr_wordlist_file <- function(short_id, study_name, dir_task,
                                     dir_eprime = "Recordings",
                                     dir_wordlist = "WordLists",
                                     read_only = TRUE, update = FALSE) {
  create_wordlist_file(
    short_id = short_id,
    study_name = study_name,
    dir_task = dir_task,
    dir_eprime = dir_eprime,
    dir_wordlist = dir_wordlist,
    read_only = read_only,
    update = update,
    task_name = "NonWordRep",
    wordlist_func = function(x) lookup_nwr_wordlist(get_nwr_trial_info(x))
  )
}




#' Create a WordList for a NWR expriment
#' @param df_trials a data-frame with trial-level information about a NWR
#'   repetition experiment
#' @return a data-frame with the "WordList" for those trials
#' @export
lookup_nwr_wordlist <- function(df_trials) {
  # Our goal here is to do a single table join to combine the trial information
  # with the word list information. For the NonWordRep experiment, this is
  # straightforward because the ItemKey column from trial-level information
  # should map onto the WorldBet column from the WordList information.

  timepoint <- unique(df_trials$TimePoint)
  eprime_file <- unique(df_trials$Eprime.Basename)

  # Get the wordlist definition
  timepoint_name <- paste0("TimePoint", timepoint)
  target_info <- int_l2t_wordlists$NonWordRep[[timepoint_name]]

  # Check for a custom wordlist
  has_custom_list <- eprime_file %in% names(int_l2t_wordlists$CustomLists)

  if (has_custom_list) {
    target_info <- int_l2t_wordlists$CustomLists[[eprime_file]]
  }

  # These are the columns we need to retain after joining the two tables
  names_to_keep <- c("TrialNumber", "TrialType", "Orthography", "WorldBet",
                     "Frame1", "Target1", "Target2", "Frame2",
                     "TargetStructure", "Frequency", "ComparisonPair")

  word_list <- df_trials %>%
    left_join(target_info, by = c("ItemKey" = "WorldBet")) %>%
    rename_(WorldBet = ~ ItemKey) %>%
    select(one_of(names_to_keep))

  word_list

  # Assert that the join worked
  stopifnot(any(!is.na(word_list$WorldBet)))
  stopifnot(any(!is.na(word_list$Orthography)))
  stopifnot(nrow(word_list) == nrow(df_trials))

  word_list
}




#' Extract trial-level data from a NWR Eprime text file
#' @param eprime_path path to an Eprime text file
#' @return a data-frame with information about each trial
#' @export
get_nwr_trial_info <- function(eprime_path) {
  trial_info <- get_trial_info(eprime_path)

  # Find the ItemKey that goes with each AudioPrompt
  trial_info$ItemKey <- trial_info$AudioPrompt

  # Clean any dialect/timepoint suffixes
  trial_info$ItemKey <- trial_info$ItemKey %>%
      stringr::str_replace_all("_.+$", "")

  # Apply any manual corrections to the item keys
  trial_info$ItemKey <- correct_nwr_items(trial_info$ItemKey)

  trial_info <- trial_info %>%
    select_(~ TimePoint, ~ Dialect, ~ Experiment, ~ Eprime.Basename,
            ~ TrialNumber, ~ TrialType, ~ ItemKey, ~ everything())

  trial_info
}

