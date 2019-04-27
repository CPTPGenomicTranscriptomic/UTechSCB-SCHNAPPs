<img src="inst/www/images/schnappsLogo.png" align="right" alt="" width="120" />

# SCHNAPPs - Single Cell sHiNy APP(s)

## Overview

Shiny app for the analysis of single cell data

## Installation

```
if (!require("devtools"))
  install.packages("devtools")
devtools::install_github("shinyMCE", "mul118")
install_github("C3BI-pasteur-fr/UTechSCB-SCHNAPPs")
```

## Running schnapps

To start the app:

```
schnapps()
```

### load data

A singleCellExperiment object is required, saved in a file RData object using 

```
save(file = "filename.RData", "singleCellExperiementObject")
```

Load a small set of 200 cells and save to a file in the local directory
```
data("scEx", package = "SCHNAPPs")
save(file = "scEx.Rdata", list = "scEx")
```


## Screen-shots

Under the following link you can find some [screen-shots](inst/www/screen_shots.md)


## Extending SCHAPPs