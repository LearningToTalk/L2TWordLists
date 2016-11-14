
<!-- README.md is generated from README.Rmd. Please edit that file -->
L2TWordLists
============

The goal of L2TWordLists is to ...

Installation
------------

You can install L2TWordLists from github with:

``` r
# install.packages("devtools")
devtools::install_github("LearningToTalk/L2TWordLists")
```

Packaged data
-------------

### Item level information for RWR tasks

``` r
library(dplyr, warn.conflicts = FALSE)
library(L2TWordLists)

l2t_wordlists
#> $RWR
#> $RWR$TimePoint1
#> # A tibble: 56 × 6
#>    Abbreviation   Word WorldBet TargetC TargetV Frame
#>           <chr>  <chr>    <chr>   <chr>   <chr> <chr>
#> 1          CAKE   cake      kek       k       e     k
#> 2          CANN    can     kaen       k      ae     n
#> 3          CARR    car      kar       k      ar  <NA>
#> 4          CATT    cat     kaet       k      ae     t
#> 5          CKIE cookie     kUki       k       U    ki
#> 6          CMRA camera   kaemr6       k      ae   mr6
#> 7          CNDY  candy   kaendi       k      ae   ndi
#> 8          COAT   coat      kot       k       o     t
#> 9          COCH  couch    kaUtS       k      aU    tS
#> 10         COLD   cold     kold       k       o    ld
#> # ... with 46 more rows
#> 
#> $RWR$TimePoint2
#> # A tibble: 78 × 6
#>    Abbreviation    Word WorldBet TargetC TargetV Frame
#>           <chr>   <chr>    <chr>   <chr>   <chr> <chr>
#> 1          CAKE    cake      kek       k       e     k
#> 2          CARR     car      kar       k      ar  <NA>
#> 3          CATT     cat     kaet       k      ae     t
#> 4          CFEE  coffee     kafi       k       a    fi
#> 5          CHAR   chair     tSEr      tS      Er  <NA>
#> 6          CHEE  cheese     tSiz      tS       i     z
#> 7          CHKN chicken   tSIkIn      tS       I   kIn
#> 8          CKIE  cookie     kUki       k       U    ki
#> 9          CNDL  candle  kaend6l       k      ae  nd6l
#> 10         CNDY   candy   kaendi       k      ae   ndi
#> # ... with 68 more rows
#> 
#> $RWR$TimePoint3
#> # A tibble: 121 × 10
#>    Abbreviation Orthography WorldBet Target1 Target2 Frame2 ComparisonPair
#>           <chr>       <chr>    <chr>   <chr>   <chr>  <chr>          <chr>
#> 1          SHRT      shorts    Sorts       S      or     ts           <NA>
#> 2          GIRL        girl     g3rl       g      3r      l           <NA>
#> 3          COLD        cold     kold       k       o     ld           <NA>
#> 4          COWW         cow      kaU       k      aU   <NA>           <NA>
#> 5          Cake        cake      kek       k       e      k           <NA>
#> 6          CATT         cat     kaet       k      ae      t           <NA>
#> 7          CFEE      coffee     kafi       k       a     fi           <NA>
#> 8         Chair       chair     tSEr      tS      Er   <NA>           <NA>
#> 9        Cheese      cheese     tSiz      tS       i      z           <NA>
#> 10      Chicken     chicken   tSIkIn      tS       I    kIn        chimmig
#> # ... with 111 more rows, and 3 more variables: Block <chr>,
#> #   AAEsoundFile <chr>, Abbreviation120 <chr>
```
