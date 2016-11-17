context("Helper functions")

test_that("We can save WordLists to read-only files", {
  testthat::skip_on_travis()

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


test_that("RWR shortcut function", {
  testthat::skip_on_travis()

  wl_dir <- test_path("l2t/RealWordRep/TimePoint1/WordLists/")

  # Clean up any leftovers from last time
  wl_dir %>%
    list.files(full.names = TRUE) %>%
    unlink(force = TRUE)

  # Using a mock location for the package documentation...
  task_dir <- test_path("l2t/RealWordRep")
  study <- "TimePoint1"
  pid <- "001L"

  expect_message(
    create_rwr_wordlist_file(pid, study, task_dir),
    regexp = "Writing file")

  # Prevent overwriting by default
  expect_error(
    create_rwr_wordlist_file(pid, study, task_dir),
    regexp = "file already exists")

  # Overwriting when `update` is TRUE
  expect_message(
    create_rwr_wordlist_file(pid, study, task_dir, update = TRUE),
    regexp = "Updating file")

  results <- suppressMessages(
    create_rwr_wordlist_file(pid, study, task_dir, update = TRUE)
  )

  # Confirm read-only
  oct_mode <- as.character(file.info(results[[1]][["path"]])[["mode"]])
  expect_equal(oct_mode, "444")


  pid <- "003L"
  expect_message(
    create_rwr_wordlist_file(pid, study, task_dir, read_only = FALSE),
    regexp = "Writing file")

  results <- suppressMessages(
    create_rwr_wordlist_file(pid, study, task_dir,
                             read_only = FALSE, update = TRUE)
  )

  # Confirm not read-only
  oct_mode <- as.character(file.info(results[[1]][["path"]])[["mode"]])
  expect_false(oct_mode == "444")

  # Failure to find a match
  expect_error(
    create_rwr_wordlist_file("failing-search", study, task_dir),
    "Could not file Eprime data"
  )

  # Remove one of the created WordLists
  unlink(results[[1]][["path"]], force = TRUE)

  # Find multiple matches...

  # Nothing happens because one of the lists has already been made
  expect_error(
    create_rwr_wordlist_file("", study, task_dir),
    "WordList file already exists"
  )

  # Message about multiple hits
  expect_message(
    create_rwr_wordlist_file("", study, task_dir, update = TRUE),
    "Multiple files found"
  )

  results <- suppressMessages(
    create_rwr_wordlist_file("", study, task_dir, update = TRUE)
  )

  # Get a list for each WordList created
  expect_equal(length(results), 2)

  # The paths returned by the function are accurate
  paths <- results %>%
    lapply(. %>% getElement("path")) %>%
    unlist
  expect_true(all(file.exists(paths)))

  # Clean up any leftovers from last time
  wl_dir %>%
    list.files(full.names = TRUE) %>%
    unlink(force = TRUE)

})
