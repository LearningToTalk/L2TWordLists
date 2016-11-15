
# Document the contents of the data folder:

#' Stimulus descriptions for L2T repetition experiments
"l2t_wordlists"




# Manually import the pipe
`%>%` <- dplyr::`%>%`

# These are manual abbreviation corrections. They were adapted from the series
# of ifelse statements in the original scripts.
abbreviation_corrections <- tibble::tribble(
  ~TimePoint, ~RawAbbr, ~CorrectAbbr,
  2,          "SHEEP",    "SHEP",
  2,          "SEDR",     "SHDR",
  2,          "TDBR",     "TEDY",
  2,          "RCKN",     "RCKG",
  2,          "SRNG",     "SHRG",
  2,          "SSSR",     "SSRS",
  3,          "SSSR",     "SSRS"
)

# Helper function that replaces uses abbreviation correction list to
correct_abbreviations <- function(xs, tp) {
  # Basically, we perform character subsetting
  # http://adv-r.had.co.nz/Subsetting.html#applications

  # Create a look-up vector. Names and values are raw abbreviations at first,
  # but we update the values to be the corrected abbreviations. The vector then
  # is a mapping from raw abbreviations to corrected abbreviations.
  item_lookup <- stats::setNames(unique(xs), unique(xs))

  # Get corrections for this timepoint
  corrections <- abbreviation_corrections %>% filter_(~ TimePoint == tp)

  # Update the look-up vector
  item_lookup[corrections$RawAbbr] <- corrections$CorrectAbbr
  item_lookup[xs]
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

