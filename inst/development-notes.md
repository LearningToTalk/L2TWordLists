# Development Notes

## Conventions

* Use RStudio and devtools. 
* Clone the package File > New Project > Version Control > Git Repository. 

We use the tools and practices from the _R Packages_ book. The whole book is
[available online](http://r-pkgs.had.co.nz/).

Using an RStudio project will settle any working directory issues by using the
package root folder as the working directory. RStudio also provides the Build
menu and Build pane for shortcuts to common package development steps, like
building the package, testing

* Edit README.Rmd

The README display on GitHub is the output of an RMarkdown file. The output from
the code examples are never manually editted and inserted, so the README
reflects reproducible behavior of the package. What you see is what the package
does (or did when the README was last compiled). In order to edit or update the
file that appears on GitHub, edit `README.Rmd` and the use the Knit button to
compile the README file.

* Do not commit any network locations for our raw data.
* Use locally packaged data for testing.

My script that copies data from our network drive to the testing folder does the
following work-around. The second `data_drive` assignment is not committed to
git or published to GitHub.

```
# Path to the drive. Depends on the user's machine
data_drive <- "SET THIS"
data_drive <- "//fake.server.address/drive_name"
```

## Packaged data

### Stimulus descriptions

Packaged data about WordList definitionsis stored in `./data-raw/` and prepared
for packaging using `./data-raw/package_wordlists.R`. If we need to update those
tables, update the files in that folder and re-run that script.

### WordList corrections

The manual corrections that are performed on the Eprime data are defined in
`./R/constants.R`. If new corrections need to be added, update that the lists in
that file.


## Other issues

### Grant write permissions to testing data

The original WordList files used for testing were copied from our shared network
drives. These files had read-only permissions. These permissions have to be
reset---done in R with `Sys.chmod(file_paths, mode = "0777")`. Otherwise, the
package checks will fail because they cannot overwrite or remove these read-only
files.
