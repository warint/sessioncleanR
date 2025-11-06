# sessioncleanr

A minimal package providing a single high-level function `clean_session()` for end-of-script hygiene in R.

## Installation

You may install from a Git hosting service using the development tools available for R. After installation, load the package with `library(sessioncleanr)`.

## Usage

Call `clean_session()` as the final statement of a script, or register it with `on.exit(clean_session(), add = TRUE)` at the beginning of a script to ensure cleanup on both normal completion and early termination.

## Notes

Deleting files under the temporary directory is irreversible. The function is conservative and does not remove user-defined scratch directories outside the temporary directory.

## References

R Core Team. (2025). R: A language and environment for statistical computing. Vienna, Austria: R Foundation for Statistical Computing.

Wickham, H. (2019). Advanced R (2nd ed.). Boca Raton, FL: CRC Press.
