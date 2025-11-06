test_that("clean_session runs without error", {
  expect_silent(clean_session(remove_objects = FALSE, run_gc = FALSE, unload_packages = FALSE, remove_tempfiles = FALSE, verbose = FALSE))
})
