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
  trial_info


  # Find the ItemKey that goes with each AudioPrompt
  dialect <- unique(trial_info$Dialect)

  trial_info$ItemKey <- trial_info$AudioPrompt

  if (dialect == "AAE") {
    trial_info$ItemKey <- trial_info$ItemKey %>%
      stringr::str_replace_all("_A$", "")
  }

  trial_info$ItemKey <- correct_nwr_items(trial_info$ItemKey)

  trial_info <- trial_info %>%
    select_(~ TimePoint, ~ Dialect, ~ Experiment, ~ Eprime.Basename,
            ~ TrialNumber, ~ TrialType, ~ ItemKey, ~ everything())

  trial_info
}


#
# ItemKeys <- function(stimulusLog) {
#   item.keys <- AudioPrompts(stimulusLog)
#   if (Experiment(Header(stimulusLog)) == 'A') {
#     item.keys <- sub(pattern = '_A',
#                      replacement = '',
#                      x = item.keys)
#   }
#
#   info <- sae_info <- get_trial_info("./tests/testthat/test-files/TimePoint1/NonWordRep_001L28FS1.txt") %>% glimpse
#   info <- aae_info <- get_trial_info("./tests/testthat/test-files/TimePoint1/NonWordRep_013L32MA1.txt") %>% glimpse
#
#
#
#
#
#   item.keys2 <- sapply(item.keys, translator_function, USE.NAMES = FALSE)
#   data_frame(item.keys, item.keys2) %>% filter(item.keys != item.keys2)
#
#   return(item.keys)
# }
#
# translator_function = function(element) {
#   badAudioNames <- c('auft6ga', 'aunt6ko', 'aupt6d', 'bod6jau',
#                      'chimmig', 'chisem', 'cuffeam', 'dqkram',
#                      'gvft6daI','jugoin', 'kahsep', 'kamig',
#                      'kh3rpoyn', 'khErpoin', 'khizel', 'kipown',
#                      'kraesem', 'kramel', 'kwalaid', 'kwameg',
#                      'kwefim', 'kwepas', 'rahlide', 'rapoin',
#                      'raybith', 'reefross', 'ruhgloke', 'ruhmaid',
#                      'saiprote', 'samell', 'seeploke', 'shaenut',
#                      'shayvoss', 'soodross', 'soudack', 'sqnut',
#                      'subbith', 'thaumag', 'thIblor', 'toezell',
#                      'toogrife', 'truhglap', 'truhtok', 'tvgn6dit',
#                      'twaiklor', 'twaipon', 'twemag', 'tyblore',
#                      'vukatEm', 'wahkrad', 'wahprote', 'waymog',
#                      'whimell', 'twefrap')
#
#   correctWorldBet <- c('aUft6ga',  'aUnt6ko',  'aUpt6d',	'bod6jaU',
#                        'tSImIg',	'tSIsEm',	'kVfim',	'daekram',
#                        'gVft6daI',	'jugoit',	'kasEp',	'kaemIg',
#                        'kh3rpoin', 'kh3rpoin', 'khIzEl',	'kIpon',
#                        'kraesEm',	'kramEl',	'kwalaId',	'kwamIg',
#                        'kwEfim',	'kwEpas',	'ralaId',	'raepoIn',
#                        'rebIT',	'rifras',	'rVglok',	'rVmaId',
#                        'saIprot',	'saemEl',	'sIplok',	'Saenut',
#                        'Sevas',	'sudras',	'sodaek',	'Saenut',
#                        'sVbIT',	'thaUmag',	'tIblor',	'tozEl',
#                        'tugraIf',	'trVglap',	'trVtok',	'tVgn6dit',
#                        'twaIklor',	'twaIpon',	'twEmag',	'taIblor',
#                        'vuk6tEm',	'wakraed',	'waprot',	'wemag',
#                        'wImEl', 'twEfrap')
# #
# #
# #     data_frame(correctWorldBet, badAudioNames)
# #
# #     sprintf('"%s" = "%s"', badAudioNames, correctWorldBet) %>% paste0(collapse = ",\n") %>% cat
# #
# #
# #   toCorrect <- which(badAudioNames == element)
# #
# #   if(length(toCorrect)) {element = correctWorldBet[toCorrect]}
# #   if(substr(element, nchar(element) - 3,nchar(element)) == "_TP3"){
# #     element = substr(element, 1, nchar(element) - 4)
# #   }
# #   return(element)
# }
#
