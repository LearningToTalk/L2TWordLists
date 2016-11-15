context("RealWordRep")

list_files <- function(...) {
  list.files(..., full.names = TRUE, recursive = TRUE)
}

df_eprime <- data_frame(
 Eprime_Path = list_files(test_path("test-files"), pattern = ".txt"),
 Study = basename(dirname(Eprime_Path)),
 Task_Admin = basename(Eprime_Path) %>% tools::file_path_sans_ext(),
 Eprime_Label = Task_Admin
)

df_wordlists <- data_frame(
 WordList_Path = list_files(test_path("expected-out"), pattern = ".txt"),
 Study = basename(dirname(WordList_Path)),
 Task_Admin = basename(WordList_Path) %>%
   stringr::str_replace("_WordList.*$", ""),
 WordList_Label = basename(WordList_Path) %>% tools::file_path_sans_ext()
)

df_files <- df_eprime %>%
  left_join(df_wordlists, by = c("Study", "Task_Admin")) %>%
  mutate(Task = stringr::str_extract(Task_Admin, "^.+WordRep"))


test_that("RWR TimePoint1 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint1")

  create_wordlist <- . %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist

  load_reference_wordlist <- . %>%
    readr::read_tsv(col_types = "cccccccccc")

  for (file_index in seq_len(nrow(df_test_set))) {

    df_curr_file <- df_test_set[file_index, ]

    this_wordlist <- df_curr_file$Eprime_Path %>%
      create_wordlist()

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
})


test_that("RWR TimePoint2 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint2")

  create_wordlist <- . %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist

  load_reference_wordlist <- . %>%
    readr::read_tsv(col_types = "cccccccccc")

  for (file_index in seq_len(nrow(df_test_set))) {

    df_curr_file <- df_test_set[file_index, ]

    this_wordlist <- df_curr_file$Eprime_Path %>%
      create_wordlist()

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
})


test_that("RWR TimePoint3 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint3")

  create_wordlist <- . %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist

  load_reference_wordlist <- . %>%
    readr::read_tsv(col_types = "cccccccccccc")

  for (file_index in seq_len(nrow(df_test_set))) {

    df_curr_file <- df_test_set[file_index, ]

    this_wordlist <- df_curr_file$Eprime_Path %>%
      create_wordlist()

    this_reference <- df_curr_file$WordList_Path %>%
      load_reference_wordlist()

    # For one test of test, ignore Frame columns because of a inconsistency with
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


    expect_equal(
      object = this_wordlist %>% filter(Word != "cracker"),
      expected = this_reference %>% filter(Word != "cracker"),
      info = "All columns test -- ignore `cracker` rows",
      label = df_curr_file$Eprime_Label,
      expected.label = df_curr_file$WordList_Label)
  }
})
