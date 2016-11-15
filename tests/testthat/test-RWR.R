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


test_that("RWR TimePoint3 WordLists match original ones", {
  df_test_set <- df_files %>%
    filter(Task == "RealWordRep", Study == "TimePoint3")

  # For now, ignore Frame columns because inconsistency with a space in the word
  # "Cracker"
  create_wordlist <- . %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist %>%
    select(-Frame)

  load_reference_wordlist <- . %>%
    readr::read_tsv(col_types = "cccccccccccc") %>%
    select(-Frame)

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

  # # Some weirdness with how there is a spcae in the reference version's frame
  # # but not this one's.
  # t1 <- test_path("test-files/RealWordRep_008L54MS5.txt")
  # df_trials <- t1 %>%
  #   get_rwr_trial_info()
  #
  # df_trials <- df_trials %>%
  #   lookup_rwr_wordlist() %>%
  #   select(-Frame)
  #
  # ref_version <- "expected-out/RealWordRep_008L54MS5_WordList.txt" %>%
  #   test_path()
  #
  # df_trials2 <- %>%
  #   select(-Frame)
  #
  # expect_equal(df_trials, df_trials2)
  #
  #
  #
  # t2 <- test_path("test-files/RealWordRep_035L57FA5.txt")
  # df_trials <- t2 %>%
  #   get_rwr_trial_info() %>%
  #   lookup_rwr_wordlist() %>%
  #   select(-Frame)
  #
  # ref_version <- "expected-out/RealWordRep_035L57FA5_WordList.txt" %>%
  #   test_path()
  #
  # df_trials2 <- readr::read_tsv(ref_version) %>%
  #   select(-Frame)
  #
  # expect_equal(df_trials, df_trials2)




})
