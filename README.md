# sessioncleanR

`sessioncleanR` provides a single, reliable function — `clean_session()` — for conservative end-of-script hygiene in R.  
It helps restore a neutral working environment by closing graphics devices, stopping parallel clusters, closing open connections, removing temporary files, unloading optional namespaces, and triggering garbage collection.  
This is particularly useful in reproducible pipelines, scheduled scripts, or automated reports that run unattended.


## Why sessioncleanR?

When working in R, memory and system resources accumulate across a session — open graphics devices, lingering parallel clusters, file connections, and temporary files can persist even after a script finishes. Over time, this affects performance, reproducibility, and reliability in automated or scheduled tasks.
sessioncleanR provides a simple, one-line solution for restoring a neutral working environment. By calling clean_session() at the end of a script—or registering it with on.exit()—users ensure that memory is freed, connections are closed, and temporary files are removed. This promotes reproducible research, robust automation, and cleaner R workflows, particularly for data science pipelines and academic computing environments.

---

## Installation

### Using **devtools**

```r
# install.packages("devtools")
devtools::install_github("warint/sessioncleanR")
```

### Using **remotes** (lighter dependency)

```r
# install.packages("remotes")
remotes::install_github("warint/sessioncleanR")
```

Then load the package:

```r
library(sessioncleanr)
```

---

## Usage

At the beginning of a script, you may register automatic cleanup:

```r
on.exit(clean_session(), add = TRUE)
```

or call it explicitly at the end:

```r
clean_session()
```

The function prints a brief summary of actions taken (e.g., closed connections, deleted temporary files) when `verbose = TRUE`.

---

## Example

```r
# Simulate a session
cl <- parallel::makeCluster(2)
pdf("example.pdf")
plot(1:5)

# Clean up at the end
clean_session()
```

**Output (abridged)**

```
Stopped 1 parallel cluster(s).
Removed 8 temporary file(s).
           used (Mb) gc trigger (Mb) limit (Mb) max used (Mb)
Ncells  571993 30.6    1180381 63.1         NA   800000 42.8
Vcells 1010929  7.8    8388608 64.0      16384  1200000  9.2
```

---

## Notes

Deleting files under the session’s temporary directory (`tempdir()`) is irreversible.
The function **never** deletes user-defined scratch directories outside `tempdir()`.
If you prefer complete isolation, consider using `callr::r()` or RStudio’s “Restart R” option between runs.

---

## License

Distributed under the **GNU General Public License v3 (GPL-3)**.
See the `DESCRIPTION` file for details.

---

## Citation

If you use this package, please cite:

> Warin, T. (2025). *sessioncleanR: Conservative End-of-Session Cleanup Utilities for R* (Version 0.1.0). GitHub.
> Available at [https://github.com/thierrywarin/sessioncleanr](https://github.com/thierrywarin/sessioncleanr)

```r
citation("sessioncleanR")
```

