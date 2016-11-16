# File-reading and processing steps shared by both tasks
get_trial_info <- function(eprime_path) {
  # Read and parse the stimulus log
  eprime_frames <- eprime_path %>%
    rprime::read_eprime() %>%
    rprime::FrameList()

  # Header
  header <- eprime_frames %>%
    rprime::filter_in("Running", "Header") %>%
    rprime::to_data_frame() %>%
    tibble::as_tibble()

  dialect <- extract_dialect(header$Experiment)
  timepoint <- extract_timepoint(header$Experiment)

  # Trial level information
  trial_info <- eprime_frames %>%
    rprime::keep_levels(2) %>%
    rprime::to_data_frame() %>%
    tibble::as_tibble() %>%
    rename_(AudioPrompt = ~ soundFile,
            PicturePrompt = ~ picFile)

  # Derived values
  trial_info <- trial_info %>%
    mutate_(
      TimePoint = ~ timepoint,
      Experiment = ~ header$Experiment,
      Dialect = ~ dialect,
      TrialType = ~ find_trial_types(Running),
      TrialNumber = ~ create_trial_numbers(TrialType)) %>%
    select_(~ -Eprime.Level, ~ -Eprime.LevelName, ~ -Eprime.FrameNumber)

  trial_info
}


#' Create trial numbers following L2T WordList conventions
#'
#' @param trial_types a character vector of the words "Familiarization" and
#'   "Test" (which indicated whether a trial is a warm-up or test trial)
#' @return a vector of L2T WordList trial numbers
#'
#' @details "Familiarization" is abbreviated to "Fam". Then trial types are
#' numbered separately. For example, `c("Familiarization", "Familiarization",
#' "Test", "Test", "Test")` would output `c("Fam1", "Fam2", "Test1", "Test2",
#' "Test3")`
#'
create_trial_numbers <- function(trial_types) {
  # Precondition: Only expected trial types appear
  stopifnot(
    all(unique(trial_types) %in% c("Familiarization", "Test"))
  )

  # Abbreviate familarization trials
  trial_types <- ifelse(trial_types == "Familiarization", "Fam", trial_types)

  # Split into different groups and add numbers to each item in group
  trial_numbers <- trial_types %>%
    split(trial_types) %>%
    lapply(add_sequence_numbers) %>%
    unlist(use.names = FALSE)

  trial_numbers
}

# Number things
#   c("a", "b", "b")  => c("a1", "b2", "b3")
add_sequence_numbers <- function(xs) {
  sprintf("%s%d", xs, seq_along(xs))
}

# Label all non-"Familiarization" trials as "Test" trials
find_trial_types <- function(xs) {
  ifelse(xs == "Familiarization", "Familiarization", "Test")
}

extract_dialect <- function(xs) {
  stringr::str_extract(xs, "AAE|SAE")
}

extract_timepoint <- function(x) {
  parsed_timepoint <- x %>%
    stringr::str_extract("TP\\d") %>%
    stringr::str_extract("\\d") %>%
    as.numeric

  # Default to TP1
  if (is.na(parsed_timepoint)) {
    parsed_timepoint <- 1
  }

  parsed_timepoint
}

