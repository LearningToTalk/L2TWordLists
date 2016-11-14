context("RWR TP3")

test_that("Same output as before", {
  # Some weirdness with how there is a spcae in the reference version's frame
  # but not this one's.
  t1 <- test_path("test-files/RealWordRep_008L54MS5.txt")
  df_trials <- t1 %>%
    get_rwr_trial_info() %>%
    get_wordlist_info() %>%
    select(-Frame)

  ref_version <- "expected-out/RealWordRep_008L54MS5_WordList.txt" %>%
    test_path()

  df_trials2 <- readr::read_tsv(ref_version) %>%
    select(-Frame)

  expect_equal(df_trials, df_trials2)



  t2 <- test_path("test-files/RealWordRep_035L57FA5.txt")
  df_trials <- t2 %>%
    get_rwr_trial_info() %>%
    get_wordlist_info() %>%
    select(-Frame)

  ref_version <- "expected-out/RealWordRep_008L54MS5_WordList.txt" %>%
    test_path()

  df_trials2 <- readr::read_tsv(ref_version) %>%
    select(-Frame)

  expect_equal(df_trials, df_trials2)




})
