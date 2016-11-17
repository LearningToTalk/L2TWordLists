
# Document the contents of the data folder:

#' Stimulus descriptions for L2T repetition experiments
"l2t_wordlists"

# Manually import the pipe
`%>%` <- dplyr::`%>%`




# These are manual abbreviation corrections. They were adapted from the series
# of ifelse statements in the original scripts.
rwr_abbreviation_corrections <- tibble::tribble(
  ~TimePoint, ~RawAbbr, ~CorrectAbbr,
  2,          "SHEEP",    "SHEP",
  2,          "SEDR",     "SHDR",
  2,          "TDBR",     "TEDY",
  2,          "RCKN",     "RCKG",
  2,          "SRNG",     "SHRG",
  2,          "SSSR",     "SSRS",
  3,          "SSSR",     "SSRS"
)

# Helper function that uses the abbreviation correction list to correct some
# item abbreviations.
correct_rwr_abbreviations <- function(xs, tp) {
  # Basically, we perform character subsetting
  # http://adv-r.had.co.nz/Subsetting.html#applications

  # Create a look-up vector. Names and values are raw abbreviations at first,
  # but we update the values to be the corrected abbreviations. The vector then
  # is a mapping from raw abbreviations to corrected abbreviations.
  item_lookup <- stats::setNames(unique(xs), unique(xs))

  # Get corrections for this timepoint
  corrections <- rwr_abbreviation_corrections %>% filter_(~ TimePoint == tp)

  # Update the look-up vector
  item_lookup[corrections$RawAbbr] <- corrections$CorrectAbbr
  item_lookup[xs]
}


# Corrections for NonWordRep items. The `RawForm` is derived from the filename
# of the .wav file played during the experiment. The `CorrectedForm` is a
# corrected WorldBet representation of the word that was presented.
nwr_item_corrections <- c(
  # "RawForm" = "CorrectedForm"
  "auft6ga"   = "aUft6ga",
  "aunt6ko"   = "aUnt6ko",
  "aupt6d"    = "aUpt6d",
  "bod6jau"   = "bod6jaU",
  "chimmig"   = "tSImIg",
  "chisem"    = "tSIsEm",
  "chinut"    = "tSInut",
  "cuffeam"   = "kVfim",
  "dqkram"    = "daekram",
  "gvft6daI"  = "gVft6daI",
  "jugoin"    = "jugoit",    # a discussed change
  "kahsep"    = "kasEp",
  "kamig"     = "kaemIg",
  "kh3rpoyn"  = "kh3rpoin",
  "khErpoin"  = "kh3rpoin",
  "khizel"    = "khIzEl",
  "kipown"    = "kIpon",
  "kraesem"   = "kraesEm",
  "kreivas"   = "krevas",
  "kramel"    = "kramEl",
  "kwalaid"   = "kwalaId",
  "kwameg"    = "kwamIg",
  "kwamig"    = "kwamIg",
  # "RawForm" = "CorrectedForm"
  "kwefim"    = "kwEfim",
  "kwepas"    = "kwEpas",
  "rahlide"   = "ralaId",
  "rapoin"    = "raepoIn",
  "raybith"   = "rebIT",
  "reefross"  = "rifras",
  "ruhgloke"  = "rVglok",
  "ruhmaid"   = "rVmaId",
  "saiprote"  = "saIprot",
  "samell"    = "saemEl",
  "seeploke"  = "sIplok",
  "shaenut"   = "Saenut",
  "shayvoss"  = "Sevas",
  "soodross"  = "sudras",
  "soudack"   = "sodaek",
  "sqnut"     = "Saenut",
  "subbith"   = "sVbIT",
  "thaumag"   = "thaUmag",
  "thIblor"   = "tIblor",
  "toezell"   = "tozEl",
  "toogrife"  = "tugraIf",
  "traevait"  = "traevaIt",
  "traibith"  = "traIbIT",
  "treimut"   = "tremut",
  "truglap"   = "trVglap",
  "truhglap"  = "trVglap",
  # "RawForm" = "CorrectedForm"
  "truhtok"   = "trVtok",
  "tvgn6dit"  = "tVgn6dit",
  "twaiklor"  = "twaIklor",
  "twaipon"   = "twaIpon",
  "twemag"    = "twEmag",
  "tyblore"   = "taIblor",
  "vukatEm"   = "vuk6tEm",
  "wahkrad"   = "wakraed",
  "wahprote"  = "waprot",
  "waymog"    = "wemag",
  "whimell"   = "wImEl",
  "twefrap"   = "twEfrap"
)

# Correct items from the NonWordRep task.
correct_nwr_items <- function(xs) {
  # We use look-up vector techniques as in the RWR correction function...

  # Start with an incorrect look-up vector. Names and values are just the raw
  # item names.
  item_lookup <- stats::setNames(unique(xs), unique(xs))

  # Find any item names that are in the master vector of corrections.
  correction_locations <- which(item_lookup %in% names(nwr_item_corrections))
  raw_to_correct <- names(item_lookup)[correction_locations]

  # Overwrite the values for any items that appeared in the corrections vector.
  # Now, we have a corrected look-up vector that maps raw item names onto
  # correct item names.
  item_lookup[raw_to_correct] <- nwr_item_corrections[raw_to_correct]
  unname(item_lookup[xs])
}





# Other constants that might be useful
l2t_wordlists_data <- list()

# Capturing groups of an L2T participant ID
l2t_wordlists_data$id_parts <- list(
  ResearchID = "([0-9]{3})",
  StudyType = "([ACLPDETM])",
  Age = "([0-9]{2})",
  Gender = "([MF])",
  Dialect = "([AS])",
  Cohort = "([1-6]{1})"
)

# Combine capturing groups to have a single expression for participant IDs
l2t_wordlists_data$id_pattern <- l2t_wordlists_data$id_parts %>%
  unlist %>%
  paste0(collapse = "")



# Locate and extract an L2T id from a string or vector of strings
extract_l2t_id <- function(xs) {
  stringr::str_extract(xs, l2t_wordlists_data$id_pattern)
}

# Parse an L2T ID into its meaningful parts
parse_l2t_id <- function(x) {
  stopifnot(length(x) == 1)
  # String -> list of matrices of matching expressions
  results <- stringr::str_match_all(x, l2t_wordlists_data$id_pattern) %>%
    # List of matrices -> list of data.frames
    lapply(as.data.frame, stringsAsFactors = FALSE) %>%
    # Extract first dataframe
    `[[`(1) %>%
    # Keep first row of dataframe
    `[`(1, , drop = FALSE) %>%
    # Rename columns and convert to list
    stats::setNames(c("FullID", names(l2t_wordlists_data$id_parts))) %>%
    as.list

  results$ShortID <- paste0(results$ResearchID, results$StudyType)
  results$original <- x
  results
}

