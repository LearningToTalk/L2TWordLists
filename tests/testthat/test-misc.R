context("Helper functions")

test_that("We can save WordLists to read-only files", {

  outpath <- tempfile("my_wordlist", fileext = ".txt")

  wordlist <- test_path("test-files/TimePoint1/RealWordRep_001L28FS1.txt") %>%
    get_rwr_trial_info() %>%
    lookup_rwr_wordlist() %>%
    write_protected_tsv(outpath)

  # Confirm read-only
  expect_warning(file.remove(outpath), regexp = "Permission denied")
  expect_error(write_protected_tsv(wordlist, outpath))

  # Saved file matches reference file
  ref_file <- test_path("expected-out/TimePoint1/RealWordRep_001L28FS1_WordList.txt") %>%
    readr::read_tsv(col_types = "cccccccccc")
  this_file <- readr::read_tsv(outpath, col_types = "cccccccccc")

  expect_equal(this_file, ref_file)

  unlink(outpath, force = TRUE)
})
