
create_wordlist_file <- function(short_id, study_name, dir_task,
                                 task_name, wordlist_func,
                                 dir_eprime = "Recordings",
                                 dir_wordlist = "WordLists",
                                 read_only = TRUE, update = FALSE) {

  write_file <- if (read_only) write_protected_tsv else readr::write_tsv

  dir_eprime <- file.path(dir_task, study_name, dir_eprime)
  dir_wordlist <- file.path(dir_task, study_name, dir_wordlist)


  if (short_id == "") {
    short_id <- "\\d{3}[A-Z]\\d{2}"
  }

  # Find Eprime data
  search_pattern <- paste0(task_name, "_", short_id, ".+txt$")
  search_results <- list.files(dir_eprime, search_pattern, full.names = TRUE)

  # Fail if nothing found
  if (length(search_results) == 0) {
    stop("Could not file Eprime data for ", short_id,
         " in folder:\n\t", dir_eprime, call. = FALSE)
  }

  # Message if multiple files found
  if (1 < length(search_results)) {
    message("Multiple files found: ",
            paste0(basename(search_results), collapse = ", "))
  }

  # Create WordList paths
  admin_name <- search_results %>%
    basename() %>%
    tools::file_path_sans_ext()

  wordlist_name <- file.path(
    dir_wordlist,
    paste0(admin_name, "_WordList.txt"))

  # Fail if WordLists exist already and we're not updating
  if (any(file.exists(wordlist_name)) & !update) {
    alreadys <- wordlist_name[which(file.exists(wordlist_name))] %>%
      paste0(collapse = "\n\t")
    stop("WordList file already exists:\n\t",
         alreadys,
         "\nUse `update = TRUE` to overwrite a WordList.",
         call. = FALSE)
  }

  if (update) {
    Sys.chmod(wordlist_name, mode = "777")
  }

  parsed <- search_results %>%
    lapply(wordlist_func)

  save_wordlist <- function(x, path) {
    verb <- if (update) "Updating file" else "Writing file"
    message(verb, " ", basename(path))
    write_file(x, path)
    x
  }

  Map(save_wordlist, parsed, wordlist_name)

  # Create a little container of file-locations and data-frames
  describe_output <- function(filepath, data) {
    list(path = filepath, data = data)
  }

  output <- unname(Map(describe_output, wordlist_name, parsed))

  invisible(output)
}



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
  helper <- header$Animal
  date <- header$SessionDate %>% as.Date(format = "%m-%d-%Y")

  # Assert that we got valid data from the header
  stopifnot(!is.na(dialect), !is.na(timepoint), !is.na(date))

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
      Helper = ~ helper,
      Date = ~ date,
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

