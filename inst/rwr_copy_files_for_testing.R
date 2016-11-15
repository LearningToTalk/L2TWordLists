library("dplyr")
library("L2TWordLists")
library("purrr")

# Path to the drive. Depends on the user's machine
data_drive <- "SET THIS"

# Locate every eprime file for RWR for a given study
study <- "TimePoint2"
stim_dir <- sprintf("DataAnalysis/RealWordRep/%s/Recordings/", study)
stim_dir_path <- file.path(data_drive, stim_dir)
stim_files <- list.files(stim_dir_path, "*.txt", full.names = TRUE)

# Locate WordList files
wl_dir <- sprintf("DataAnalysis/RealWordRep/%s/WordLists/", study)
wl_dir_path <- file.path(data_drive, wl_dir)
wl_files <- list.files(wl_dir_path, "*.txt", full.names = TRUE)

# Load every (non-archived) eprime file
trial_info <- stim_files %>%
  map(get_rwr_trial_info)

# Determine which versions of the experiment were most commonly administered
trial_counts <- trial_info %>%
  bind_rows() %>%
  count(Experiment, Eprime.Basename) %>%
  ungroup %>%
  rename(TrialCount = n) %>%
  count(Experiment, TrialCount) %>%
  ungroup %>%
  rename(nFiles = n)
trial_counts



# Locate files for testing. Find unique combinations of dialect, experiment
# name, trial numbers.
files_for_testing <- trial_info %>%
  # Add the file path as an additional column. Need to use map2 because we are
  # threading a vector of filepaths into a list of dataframes
  map2(stim_files, ~ mutate(.x, FilePath = .y)) %>%
  bind_rows() %>%
  # Count trials in each administration
  group_by(Eprime.Basename) %>%
  mutate(nTrials = n()) %>%
  ungroup %>%
  # Keep first file for each unique combinations of experiment attributes
  group_by(TimePoint, Dialect, Experiment, nTrials) %>%
  summarise(RWR_Admin = first(Eprime.Basename),
            Eprime_FilePath = first(FilePath),
            Eprime_Basename = basename(Eprime_FilePath)) %>%
  ungroup
files_for_testing


# Locate the corresponding WordList files for these testing files
wl_file_df <- data_frame(
  WordList_Path = wl_files,
  WordList_Basename = wl_files %>% basename,
  RWR_Admin = stringr::str_replace(WordList_Basename, "_WordList.*$", ""))
wl_file_df

# Combine the WordList file info with the Eprime info
files_for_testing <- files_for_testing %>%
  left_join(wl_file_df) %>%
  select(TimePoint:RWR_Admin, WordList_Basename, everything())

# Copy the files
test_dir_stim <- file.path("./tests/testthat/test-files", study)
test_dir_wl <- file.path("./tests/testthat/expected-out", study)
dir.create(test_dir_stim)
dir.create(test_dir_wl)

file.copy(files_for_testing$Eprime_FilePath, test_dir_stim)
file.copy(files_for_testing$WordList_Path, test_dir_wl)
