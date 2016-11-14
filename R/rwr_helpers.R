#' @export
get_rwr_trial_info <- function(stimulusLog) {
  # Read and parse the stimulus log
  eprime_frames <- stimulusLog %>%
    rprime::read_eprime() %>%
    rprime::FrameList()

  # Header
  header <- eprime_frames %>%
    rprime::filter_in("Running", "Header") %>%
    rprime::to_data_frame() %>%
    tibble::as_tibble()

  dialect <- extract_dialect(header$Experiment)
  timepoint <- get_timepoint(header$Experiment)

  # Trial level information
  trial_info <- eprime_frames %>%
    rprime::keep_levels(2) %>%
    rprime::to_data_frame() %>%
    tibble::as_tibble() %>%
    rename(AudioPrompt = soundFile, PicturePrompt = picFile)

  # Derived values
  trial_info <- trial_info %>%
    mutate(
      Abbreviation = get_word_abbreviations(AudioPrompt),
      TrialType = ifelse(Running == "Familiarization", "Familiarization", "Test"),
      TrialNumber = create_trial_numbers(TrialType),
      Block = stringr::str_replace(Running, "List", "block"),
      Dialect = dialect,
      Experiment = header$Experiment,
      TimePoint = timepoint) %>%
    select(-Eprime.Level, -Eprime.LevelName, -Eprime.FrameNumber) %>%
    select(TimePoint, Dialect, Experiment, Eprime.Basename, Block, TrialNumber,
           TrialType, Abbreviation, everything())

  # Correct any abbreviations
  trial_info$Abbreviation <- trial_info$Abbreviation %>%
    correct_abbreviations(timepoint)

  trial_info
}

#' @export
get_wordlist_info <- function(df_trials) {
  # Our goal here is to do a single table join to combine the trial information
  # with the word list information. We have to use the timepoint, dialect, and
  # number of trials in order to figure out how to join the tables. So most of
  # this function is getting the pieces in place for the table join.

  timepoint <- unique(df_trials$TimePoint)
  dialect <- unique(df_trials$Dialect)
  num_trials <- nrow(df_trials)

  # Get the wordlist definition
  target_info <- l2t_wordlists$RWR[[paste0("TimePoint", timepoint)]]

  # The TP3 wordlist has two "abbreviation" columns, depending on the dialect
  # and number of trials. Determine which to use.
  abbreviation_set <- if (num_trials == 120 & dialect == 'SAE') {
    "Abbreviation120"
  } else {
    "Abbreviation"
  }

  # These are the rules for combining the trial info and the wordlist. See
  # documentation in ?left_join for the "by" argument to learn how these rules
  # work.
  by_rules <- list(
    SAE1 = c("Abbreviation"),
    AAE1 = c("Abbreviation"),
    SAE2 = c("Abbreviation"),
    AAE2 = c("Abbreviation"),
    SAE3 = c("Abbreviation" = abbreviation_set, "Block"),
    AAE3 = c("AudioPrompt" = "AAEsoundFile", "Block"))

  # Choose the rule
  current_case <- paste0(dialect, timepoint)
  current_rule <- by_rules[[current_case]]

  # These are the columns we need to retain afterwards.
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



get_timepoint <- function(xs) {
  xs %>%
    stringr::str_extract("TP\\d") %>%
    stringr::str_extract("\\d") %>%
    as.numeric
}


# GetWordAbbreviations <- function(audioPrompt) {
#   # Description:
#   #   Extract the abbreviation of target words from names of audio prompts.
#   # Arguments:
#   #   audioPrompt: A character vector, each of whose elements is the name of
#   #                an audio prompt used in the Real Word Repetition task.
#   #                Typically, the result of a call to GetAudioPrompts().
#   # Value:
#   #   A character vector, the n-th element of which is the abbreviation of
#   #   the target word associated with the audio prompt of the n-th trial
#   #   of a Real Word Repetition task.
#
#   word.abbrs <- ExtractRegExpr(x = audioPrompt, pattern = '^[^_]+')
#   return(word.abbrs)
# }

get_word_abbreviations <- function(audio_prompts) {
  stringr::str_extract(audio_prompts, pattern = '^[^_]+')
}


# TrialTypes2TrialNums <- function(trialTypes) {
#   fam.trial     <- 1
#   test.trial    <- 1
#   trial.numbers <- c()
#   for (trial.type in trialTypes) {
#     if (trial.type == 'Familiarization') {
#       trial.num <- sprintf('Fam%d', fam.trial)
#       fam.trial <- fam.trial + 1
#     } else if (trial.type == 'Test') {
#       trial.num <- sprintf('Test%d', test.trial)
#       test.trial <- test.trial + 1
#     } else {
#       trial.num <- ''
#     }
#     trial.numbers <- c(trial.numbers, trial.num)
#   }
#   return(trial.numbers)
# }
#

create_trial_numbers <- function(trial_types) {
  # Abbreviate
  trial_types <- ifelse(trial_types == "Familiarization", "Fam", trial_types)

  add_sequence_numbers <- function(xs) {
    sprintf("%s%d", xs, seq_along(xs))
  }

  # Split into different groups and add numbers to each item in group
  trial_numbers <- trial_types %>%
    split(trial_types) %>%
    Map(add_sequence_numbers, .) %>%
    unlist(use.names = FALSE)

  trial_numbers
}


# GetDialect <- function(stimulusLog){
#   dialect <- grep(pattern = 'Experiment:', x = stimulusLog, value = TRUE)
#   # Extract the name of the picture prompt from the grep'ed lines of text.
#   dialect <- substr(dialect, 13, 15)
#   return(dialect[1])
# }

extract_dialect <- function(xs) {
  stringr::str_extract(xs, "AAE|SAE")
}