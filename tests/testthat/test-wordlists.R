# Helpers for the rests of the tests

list_files <- function(...) {
  list.files(..., full.names = TRUE, recursive = TRUE)
}

# Load but don't print parsing information
load_reference_wordlist <- function(path) {
  suppressMessages(readr::read_tsv(path))
}

# Files for testing
df_eprime <- data_frame(
  Eprime_Path = list_files(test_path("test-files"), pattern = ".txt"),
  Study = Eprime_Path %>% dirname %>% basename,
  Task_Admin = Eprime_Path %>% basename %>% tools::file_path_sans_ext(),
  Eprime_Label = Task_Admin
)

df_wordlists <- data_frame(
  WordList_Path = list_files(test_path("expected-out"), pattern = ".txt"),
  Study = WordList_Path %>% dirname %>% basename,
  Task_Admin = WordList_Path %>% basename %>%
    stringr::str_replace("_WordList.*$", ""),
  WordList_Label = WordList_Path %>% basename %>% tools::file_path_sans_ext()
)

df_files <- df_eprime %>%
  left_join(df_wordlists, by = c("Study", "Task_Admin")) %>%
  mutate(Task = stringr::str_extract(Task_Admin, "^.+WordRep")) %>%
  select(Task, Study, Task_Admin, Eprime_Label, WordList_Label,
         Eprime_Path, WordList_Path)

create_rwr_wordlist <- . %>%
  get_rwr_trial_info() %>%
  lookup_rwr_wordlist()

create_nwr_wordlist <- . %>%
  get_nwr_trial_info() %>%
  lookup_nwr_wordlist()


# For each row in a data-frame of file information, compare the wordlist created
# by the package to the reference versions. Test fails if the two data-frame are
# not the same.
test_wordlists <- function(df_test_files, func_create_wordlist) {
  for (file_index in seq_len(nrow(df_test_files))) {
    df_curr_file <- df_test_files[file_index, ]

    this_wordlist <- df_curr_file$Eprime_Path %>%
      func_create_wordlist()

    this_reference <- df_curr_file$WordList_Path %>%
      load_reference_wordlist()

    expect_equal(
      object = this_wordlist,
      expected = this_reference,
      label = df_curr_file$Eprime_Label,
      expected.label = df_curr_file$WordList_Label)

    # # diagnostics - to visualize the cell-by-cell differences
    # daff::diff_data(this_wordlist, data_ref = this_reference) %>%
    #  daff::render_diff()
  }
}




context("RealWordRep")

test_that("RWR TimePoint1 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint1")

  test_wordlists(df_test_set, create_rwr_wordlist)
})


test_that("RWR TimePoint2 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint2")

  test_wordlists(df_test_set, create_rwr_wordlist)
})


test_that("RWR TimePoint3 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint3")

  create_wordlist <- . %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist()

  for (file_index in seq_len(nrow(df_test_set))) {

    df_curr_file <- df_test_set[file_index, ]

    this_wordlist <- df_curr_file$Eprime_Path %>%
      create_wordlist()

    this_reference <- df_curr_file$WordList_Path %>%
      load_reference_wordlist()

    # For one set of tests, ignore Frame columns because of a inconsistency with
    # a space in the Frame for the word "Cracker". The master wordlist has no
    # space. The individual files created by the old script do have a space.
    expect_equal(
      object = this_wordlist %>% select(-Frame),
      expected = this_reference %>% select(-Frame),
      info = "All rows test -- ignore `Frame` column",
      label = df_curr_file$Eprime_Label,
      expected.label = df_curr_file$WordList_Label)

    # # diagnostics - to visualize the cell-by-cell differences
    # daff::diff_data(this_wordlist, data_ref = this_reference) %>%
    #  daff::render_diff()

    # For another set of tests, ignore the "cracker" rows.
    expect_equal(
      object = this_wordlist %>% filter(Word != "cracker"),
      expected = this_reference %>% filter(Word != "cracker"),
      info = "All columns test -- ignore `cracker` rows",
      label = df_curr_file$Eprime_Label,
      expected.label = df_curr_file$WordList_Label)
  }
})

test_that("RWR CochlearV1/2 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study %in% c("CochlearV1", "CochlearV2"))

  test_wordlists(df_test_set, create_rwr_wordlist)
})




context("NonWordRep")

test_that("NWR TimePoint1 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "NonWordRep", Study == "TimePoint1")

  test_wordlists(df_test_set, create_nwr_wordlist)
})


test_that("NWR TimePoint2 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "NonWordRep", Study == "TimePoint2")

  test_wordlists(df_test_set, create_nwr_wordlist)
})

test_that("NWR TimePoint3 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "NonWordRep", Study == "TimePoint3")

  test_wordlists(df_test_set, create_nwr_wordlist)
})

