

#' @export
#' @rdname create_wordlists
create_rwr_wordlist_file <- function(short_id, study_name, dir_task,
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
    task_name = "RealWordRep",
    wordlist_func = function(x) lookup_rwr_wordlist(get_rwr_trial_info(x))
  )
}


#' Extract trial-level data from a RWR Eprime text file
#' @param eprime_path path to an Eprime text file
#' @return a data-frame with information about each trial
#' @export
get_rwr_trial_info <- function(eprime_path) {
  trial_info <- get_trial_info(eprime_path)

  # Additional steps for RWR files. Downstream table joins with the word-lists
  # use either the Abbreviation, Abbreviation/Block, or SoundFile/Block fields,
  # so we need to add them here.
  trial_info <- trial_info %>%
    mutate_(
      Trial_Abbreviation = ~ get_word_abbreviations(AudioPrompt),
      Block = ~ stringr::str_replace(Running, "List", "block")) %>%
    select_(~ TimePoint, ~ Dialect, ~ Experiment, ~ Eprime.Basename, ~ Block,
            ~ TrialNumber, ~ TrialType, ~ Trial_Abbreviation, ~ everything())

  # Correct any abbreviations
  timepoint <- unique(trial_info$TimePoint)
  trial_info$Trial_Abbreviation <- trial_info$Trial_Abbreviation %>%
    correct_rwr_abbreviations(timepoint)

  trial_info
}

#' Create a WordList for a RWR expriment
#' @param df_trials a data-frame with trial-level information about a RWR
#'   repetition experiment
#' @return a data-frame with the "WordList" for those trials
#' @export
lookup_rwr_wordlist <- function(df_trials) {
  # Our goal here is to do a single table join to combine the trial information
  # with the word list information. We have to use the timepoint, dialect, and
  # number of trials in order to figure out how to join the tables. So most of
  # this function is getting the pieces in place for the table join.
  #
  # There are two columns with the item abreviations:
  #
  # - WL_Abbreviation is the abbreviation in the WordLists
  # - Trial_Abbreviation is the abbreviation in data-frame of trial information
  #
  # For most of the cases, we just join the two tables using these two columns,
  # but there are cases where we have to join using a different column in the
  # WordList table.

  timepoint <- unique(df_trials$TimePoint)
  dialect <- unique(df_trials$Dialect)
  experiment <- unique(df_trials$Experiment)
  num_trials <- nrow(df_trials)
  eprime_file <- unique(df_trials$Eprime.Basename)

  # Get the wordlist definition
  timepoint_name <- paste0("TimePoint", timepoint)
  target_info <- int_l2t_wordlists$RealWordRep[[timepoint_name]]

  # Check for a custom wordlist
  has_custom_list <- eprime_file %in% names(int_l2t_wordlists$CustomLists)

  if (has_custom_list) {
    target_info <- int_l2t_wordlists$CustomLists[[eprime_file]]
  }

  target_info <- target_info %>%
    rename_(WL_Abbreviation = ~ Abbreviation)

  # The TP3 wordlist has two "Abbreviation" columns, depending on the dialect
  # and number of trials. Determine which to use.
  abbreviation_set <- if (experiment == "SAE_RealWordRep_BLOCKED_TP3.zeta") {
    "Abbreviation120"
  } else {
    "WL_Abbreviation"
  }

  # Duplicate the Abbreviation column so there is always a column named
  # "Abbreviation" after joining. The joining rules will cause WL_Abbreviation
  # to be renamed to Trial_Abbreviation in most cases, but for the special
  # cases, this might not be true Having the duplicated "Abbreviation"
  # column avoids this issue.
  target_info$Abbreviation <- target_info[[abbreviation_set]]

  # These are the rules for combining the trial info and the wordlist. See
  # documentation in ?left_join for the "by" argument to learn how these rules
  # work.
  by_rules <- list(
    SAE1 = c("Trial_Abbreviation" = "WL_Abbreviation"),
    AAE1 = c("Trial_Abbreviation" = "WL_Abbreviation"),
    SAE2 = c("Trial_Abbreviation" = "WL_Abbreviation"),
    AAE2 = c("Trial_Abbreviation" = "WL_Abbreviation"),
    SAE3 = c("Trial_Abbreviation" = abbreviation_set, "Block"),
    AAE3 = c("AudioPrompt" = "AAEsoundFile", "Block"))

  # Choose the rule
  current_case <- paste0(dialect, timepoint)
  current_rule <- by_rules[[current_case]]

  # These are the columns we need to retain afterwards
  names_to_keep <- list(
    `1` = c('TrialNumber','Abbreviation', 'Word', 'WorldBet',
            'TargetC', 'TargetV', 'Frame', 'TrialType',
            'AudioPrompt', 'PicturePrompt'),
    `2` = c('TrialNumber','Abbreviation', 'Word', 'WorldBet',
            'TargetC', 'TargetV', 'Frame', 'TrialType',
            'AudioPrompt', 'PicturePrompt'),
    `3` = c('TrialNumber', 'Abbreviation', 'Word', 'WorldBet',
            'TargetC', 'TargetV', 'Frame', 'ComparisonPair', 'Block',
            'TrialType', 'AudioPrompt', 'PicturePrompt')
  )
  current_names_to_keep <- names_to_keep[[as.character(timepoint)]]

  # Combine the tables
  word_list <- df_trials %>%
    left_join(target_info, by = current_rule) %>%
    select(one_of(current_names_to_keep))

  # Assert that the join worked
  stopifnot(any(!is.na(word_list$WorldBet)))
  stopifnot(nrow(word_list) == nrow(df_trials))

  word_list
}





get_word_abbreviations <- function(audio_prompts) {
  stringr::str_extract(audio_prompts, pattern = '^[^_]+')
}


