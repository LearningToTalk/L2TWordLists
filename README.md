
<!-- README.md is generated from README.Rmd. Please edit that file -->
L2TWordLists
============

[![Travis-CI Build Status](https://travis-ci.org/LearningToTalk/L2TWordLists.svg?branch=master)](https://travis-ci.org/LearningToTalk/L2TWordLists)

The goal of L2TWordLists is to provide some convenient high-level functions for working with Eprime files produced by our real-word repetition and non-word repetition experiments.

Installation
------------

Install L2TWordLists from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("LearningToTalk/L2TWordLists")
```

Usage
-----

Parse an Eprime file to get trial-level information:

``` r
library(dplyr, warn.conflicts = FALSE)
library(L2TWordLists)

rwr_file <- "./tests/testthat/test-files/TimePoint3/RealWordRep_008L54MS5.txt"

# Parse Eprime file
df_rwr_trials <- get_rwr_trial_info(rwr_file)
df_rwr_trials
#> # A tibble: 119 × 19
#>    TimePoint Dialect                       Experiment
#>        <dbl>   <chr>                            <chr>
#> 1          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 2          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 3          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 4          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 5          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 6          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 7          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 8          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 9          3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> 10         3     SAE SAE_RealWordRep_BLOCKED_TP3.beta
#> # ... with 109 more rows, and 16 more variables: Eprime.Basename <chr>,
#> #   Block <chr>, TrialNumber <chr>, TrialType <chr>,
#> #   Trial_Abbreviation <chr>, Procedure <chr>, Running <chr>,
#> #   AudioPrompt <chr>, PicturePrompt <chr>, Cycle <chr>, Sample <chr>,
#> #   UserOrth <chr>, Reinforcer <chr>, reinforceImage <chr>, Helper <chr>,
#> #   Date <date>
```

Create a WordList table using that trial-level information:

``` r
df_rwr_wordlist <- lookup_rwr_wordlist(df_rwr_trials)
df_rwr_wordlist
#> # A tibble: 119 × 12
#>    TrialNumber Abbreviation   Word WorldBet TargetC TargetV Frame
#>          <chr>        <chr>  <chr>    <chr>   <chr>   <chr> <chr>
#> 1         Fam1         SHRT shorts    Sorts       S      or    ts
#> 2         Fam2         GIRL   girl     g3rl       g      3r     l
#> 3         Fam3         COLD   cold     kold       k       o    ld
#> 4         Fam4         COWW    cow      kaU       k      aU  <NA>
#> 5        Test1        SHEEP  sheep      Sip       S       i     p
#> 6        Test2         ROCK   rock      rak       r       a     k
#> 7        Test3         Roof   roof      rUf       r       U     f
#> 8        Test4       Crying crying   kraIIN       k       r  aIIN
#> 9        Test5       Shadow shadow    Saedo       S      ae    do
#> 10       Test6         SHVL shovel    SVv6l       S       V   v6l
#> # ... with 109 more rows, and 5 more variables: ComparisonPair <chr>,
#> #   Block <chr>, TrialType <chr>, AudioPrompt <chr>, PicturePrompt <chr>
```

Analogous functions are available for the nonword-repetition task.

``` r
nwr_file <- "./tests/testthat/test-files/TimePoint3/NonWordRep_001L53FS5.txt"

# Parse Eprime file
df_nwr_trials <- get_nwr_trial_info(nwr_file)
df_nwr_trials
#> # A tibble: 76 × 22
#>    TimePoint Dialect         Experiment      Eprime.Basename TrialNumber
#>        <dbl>   <chr>              <chr>                <chr>       <chr>
#> 1          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam1
#> 2          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam2
#> 3          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam3
#> 4          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam4
#> 5          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam5
#> 6          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5        Fam6
#> 7          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5       Test1
#> 8          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5       Test2
#> 9          3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5       Test3
#> 10         3     SAE SAE_NonWordRep_TP3 NonWordRep_001L53FS5       Test4
#> # ... with 66 more rows, and 17 more variables: TrialType <chr>,
#> #   ItemKey <chr>, Procedure <chr>, Running <chr>, AudioPrompt <chr>,
#> #   PicturePrompt <chr>, Cycle <chr>, Sample <chr>,
#> #   FamVisualPresentation.OnsetTime <chr>, UserOrth <chr>,
#> #   FamITI.OnsetTime <chr>, Reinforcer <chr>, reinforceImage <chr>,
#> #   VisualPresentation.OnsetTime <chr>, ITI.OnsetTime <chr>, Helper <chr>,
#> #   Date <date>

# Create Wordlist
df_nwr_wordlist <- lookup_nwr_wordlist(df_nwr_trials)
df_nwr_wordlist
#> # A tibble: 76 × 11
#>    TrialNumber       TrialType Orthography WorldBet Frame1 Target1 Target2
#>          <chr>           <chr>       <chr>    <chr>  <chr>   <chr>   <chr>
#> 1         Fam1 Familiarization      dablor   dablor   <NA>       d       a
#> 2         Fam2 Familiarization      dqkram  daekram   <NA>       d      ae
#> 3         Fam3 Familiarization       sqnut   Saenut   <NA>       S      ae
#> 4         Fam4 Familiarization    kh3rpoyn kh3rpoin   <NA>       k      3r
#> 5         Fam5 Familiarization      khizel   khIzEl   <NA>       k       I
#> 6         Fam6 Familiarization     thaumag  thaUmag   <NA>       t      aU
#> 7        Test1            Test     twefrap  twEfrap   <NA>       t       w
#> 8        Test2            Test   vookuhtem  vuk6tEm   <NA>       v       u
#> 9        Test3            Test  gufftuhdye gVft6daI     gV       f       t
#> 10       Test4            Test      baydag   bedaeg    bed      ae       g
#> # ... with 66 more rows, and 4 more variables: Frame2 <chr>,
#> #   TargetStructure <chr>, Frequency <chr>, ComparisonPair <chr>
```

Save a read-only copy of a WordList table:

``` r
# Save wordlist to a temporary file (for illustration purposes)
outpath <- tempfile("my-wordlist", fileext = ".txt")
write_protected_tsv(df_rwr_wordlist, outpath)

# mode is `444` when a file is read-only
file.info(outpath)[["mode"]]
#> [1] "444"

# returns -1 when write permissions are unavailable
unname(file.access(outpath, 2))
#> [1] -1
```

### Create a WordList from a Participant ID

The functions `create_rwr_wordlist_file()` and `create_nwr_wordlist_file()` are shortcuts that will create a WordList for a particular participant. These functions replicate the main functionality of our older R scripts. All the user needs to provide is a participant ID, a study name, and a task directory.

``` r
# Using a mock location for the package documentation...
task_dir <- "./tests/testthat/l2t/RealWordRep"
study_name <- "TimePoint1"
participant_id <- "001L"

create_rwr_wordlist_file(participant_id, study_name, task_dir)
#> Writing file RealWordRep_001L28FS1_WordList.txt
```

Here's an analogous example for nonword repetition.

``` r
nwr_task_dir <- "./tests/testthat/l2t/NonWordRep"
nwr_study_name <- "TimePoint1"
nwr_participant_id <- "124L"

create_nwr_wordlist_file(nwr_participant_id, nwr_study_name, nwr_task_dir)
#> Writing file NonWordRep_124L28MS1_WordList.txt
```

#### WordList creation options

The following examples show the options available to both functions, but use only the real-word-repetition function for conciseness.

By default, the function will not overwrite a WordList.

``` r
create_rwr_wordlist_file(participant_id, study_name, task_dir)
#> Error: WordList file already exists:
#>  ./tests/testthat/l2t/RealWordRep/TimePoint1/WordLists/RealWordRep_001L28FS1_WordList.txt
#> Use `update = TRUE` to overwrite a WordList.
```

We can update a WordList with `update = TRUE`, however:

``` r
create_rwr_wordlist_file(participant_id, study_name, task_dir, update = TRUE)
#> Updating file RealWordRep_001L28FS1_WordList.txt
```

If we set the participant ID to a blank `""`, then the function will **create a WordList for every participant ID in a study** folder.

``` r
create_rwr_wordlist_file("", study_name, task_dir, update = TRUE)
#> Multiple files found: RealWordRep_001L28FS1.txt, RealWordRep_003L31FS1.txt
#> Updating file RealWordRep_001L28FS1_WordList.txt
#> Updating file RealWordRep_003L31FS1_WordList.txt
```

The function invisibly returns a list with the generated WordList and the file location. That is, we can run the function by itself and not see the generated WordList printed out --- this prevents the console from being flooded with data-frame print-outs. But we can assign the results of the function to a variable and see the WordList data and file locations. In this case, two WordsLists have been updated:

``` r
results <- create_rwr_wordlist_file("", study_name, task_dir, update = TRUE)
#> Multiple files found: RealWordRep_001L28FS1.txt, RealWordRep_003L31FS1.txt
#> Updating file RealWordRep_001L28FS1_WordList.txt
#> Updating file RealWordRep_003L31FS1_WordList.txt
str(results)
#> List of 2
#>  $ :List of 2
#>   ..$ path: chr "./tests/testthat/l2t/RealWordRep/TimePoint1/WordLists/RealWordRep_001L28FS1_WordList.txt"
#>   ..$ data:Classes 'tbl_df', 'tbl' and 'data.frame': 103 obs. of  10 variables:
#>   .. ..$ TrialNumber  : chr [1:103] "Fam1" "Fam2" "Fam3" "Fam4" ...
#>   .. ..$ Abbreviation : chr [1:103] "SHRT" "GIRL" "COLD" "COWW" ...
#>   .. ..$ Word         : chr [1:103] "shorts" "girl" "cold" "cow" ...
#>   .. ..$ WorldBet     : chr [1:103] "Sorts" "g3rl" "kold" "kaU" ...
#>   .. ..$ TargetC      : chr [1:103] "S" "g" "k" "k" ...
#>   .. ..$ TargetV      : chr [1:103] "or" "3r" "o" "aU" ...
#>   .. ..$ Frame        : chr [1:103] "ts" "l" "ld" NA ...
#>   .. ..$ TrialType    : chr [1:103] "Familiarization" "Familiarization" "Familiarization" "Familiarization" ...
#>   .. ..$ AudioPrompt  : chr [1:103] "SHRT_H_01" "GIRL_H_01" "COLD_H_01" "COWW_H_01" ...
#>   .. ..$ PicturePrompt: chr [1:103] "SHRT_01" "GIRL_01" "COLD_01" "COWW_01" ...
#>  $ :List of 2
#>   ..$ path: chr "./tests/testthat/l2t/RealWordRep/TimePoint1/WordLists/RealWordRep_003L31FS1_WordList.txt"
#>   ..$ data:Classes 'tbl_df', 'tbl' and 'data.frame': 103 obs. of  10 variables:
#>   .. ..$ TrialNumber  : chr [1:103] "Fam1" "Fam2" "Fam3" "Fam4" ...
#>   .. ..$ Abbreviation : chr [1:103] "SHRT" "GIRL" "COLD" "COWW" ...
#>   .. ..$ Word         : chr [1:103] "shorts" "girl" "cold" "cow" ...
#>   .. ..$ WorldBet     : chr [1:103] "Sorts" "g3rl" "kold" "kaU" ...
#>   .. ..$ TargetC      : chr [1:103] "S" "g" "k" "k" ...
#>   .. ..$ TargetV      : chr [1:103] "or" "3r" "o" "aU" ...
#>   .. ..$ Frame        : chr [1:103] "ts" "l" "ld" NA ...
#>   .. ..$ TrialType    : chr [1:103] "Familiarization" "Familiarization" "Familiarization" "Familiarization" ...
#>   .. ..$ AudioPrompt  : chr [1:103] "SHRT_H_01" "GIRL_H_01" "COLD_H_01" "COWW_H_01" ...
#>   .. ..$ PicturePrompt: chr [1:103] "SHRT_01" "GIRL_01" "COLD_01" "COWW_01" ...
```

Packaged stimulus information
-----------------------------

Tables of stimulus information about the items in our word-repetition experiments are bundled with the package and accessible with `l2t_wordlists`.

Default forms of the list are stored by Task and TimePoint, and custom one-off lists are stored in a separate list.

``` r
l2t_wordlists
#> $RealWordRep
#> $RealWordRep$TimePoint1
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
#> $RealWordRep$TimePoint2
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
#> $RealWordRep$TimePoint3
#> # A tibble: 121 × 10
#>    Abbreviation    Word WorldBet TargetC TargetV Frame ComparisonPair
#>           <chr>   <chr>    <chr>   <chr>   <chr> <chr>          <chr>
#> 1          SHRT  shorts    Sorts       S      or    ts           <NA>
#> 2          GIRL    girl     g3rl       g      3r     l           <NA>
#> 3          COLD    cold     kold       k       o    ld           <NA>
#> 4          COWW     cow      kaU       k      aU  <NA>           <NA>
#> 5          Cake    cake      kek       k       e     k           <NA>
#> 6          CATT     cat     kaet       k      ae     t           <NA>
#> 7          CFEE  coffee     kafi       k       a    fi           <NA>
#> 8         Chair   chair     tSEr      tS      Er  <NA>           <NA>
#> 9        Cheese  cheese     tSiz      tS       i     z           <NA>
#> 10      Chicken chicken   tSIkIn      tS       I   kIn        chimmig
#> # ... with 111 more rows, and 3 more variables: Block <chr>,
#> #   AAEsoundFile <chr>, Abbreviation120 <chr>
#> 
#> 
#> $NonWordRep
#> $NonWordRep$TimePoint1
#> # A tibble: 50 × 11
#>    Orthography WorldBet Frame1 Target1 Target2 Frame2     AudioFileAAE
#>          <chr>    <chr>  <chr>   <chr>   <chr>  <chr>            <chr>
#> 1      yougoyt   jugoit     ju       g      oi      t       jugoit.wav
#> 2       bogeeb    bogib     bo       g       i      b   bogib_01_A.wav
#> 3      moypudd   moip6d   <NA>       m      oi    p6d  moip6d_01_A.wav
#> 4       mabbep   maebEp   <NA>       m      ae    bEp  maebEp_01_A.wav
#> 5      voogeem    vugim   <NA>       v       u    gim   vugim_01_A.wav
#> 6       viddag   vIdaeg   <NA>       v       I   daeg  vIdaeg_01_A.wav
#> 7    vookuhtem  vuk6tEm   <NA>       v       u  k6tEm vuk6tEm_01_A.wav
#> 8     viddigop  vIt6gap   <NA>       v       I  t6gap vIt6gap_02_A.wav
#> 9     boduhyow  bod6jaU   bod6       j      aU   <NA> bod6jaU_01_A.wav
#> 10   mayduhyou   med6ju   med6       j       u   <NA>  med6ju_01_A.wav
#> # ... with 40 more rows, and 4 more variables: AudioFileSAE <chr>,
#> #   TargetStructure <chr>, Frequency <chr>, ComparisonPair <chr>
#> 
#> $NonWordRep$TimePoint2
#> # A tibble: 75 × 11
#>    Orthography WorldBet Frame1 Target1 Target2 Frame2     AudioFileAAE
#>          <chr>    <chr>  <chr>   <chr>   <chr>  <chr>            <chr>
#> 1      yougoyt   jugoit     ju       g      oi      t       jugoit.wav
#> 2       bogeeb    bogib     bo       g       i      b   bogib_01_A.wav
#> 3      moypudd   moip6d   <NA>       m      oi    p6d  moip6d_01_A.wav
#> 4       mabbep   maebEp   <NA>       m      ae    bEp  maebEp_01_A.wav
#> 5      voogeem    vugim   <NA>       v       u    gim   vugim_01_A.wav
#> 6       viddag   vIdaeg   <NA>       v       I   daeg  vIdaeg_01_A.wav
#> 7    vookuhtem  vuk6tEm   <NA>       v       u  k6tEm vuk6tEm_01_A.wav
#> 8     viddigop  vIt6gap   <NA>       v       I  t6gap vIt6gap_02_A.wav
#> 9     boduhyow  bod6jaU   bod6       j      aU   <NA> bod6jaU_01_A.wav
#> 10   mayduhyou   med6ju   med6       j       u   <NA>  med6ju_01_A.wav
#> # ... with 65 more rows, and 4 more variables: AudioFileSAE <chr>,
#> #   TargetStructure <chr>, Frequency <chr>, ComparisonPair <chr>
#> 
#> $NonWordRep$TimePoint3
#> # A tibble: 91 × 15
#>    OrigOrder Orthography WorldBet Frame1 Target1 Target2 Frame2
#>        <int>       <chr>    <chr>  <chr>   <chr>   <chr>  <chr>
#> 1         27    owftuhga  aUft6ga   <NA>      aU       f   t6ga
#> 2         25   owkpuhday  aUkp6de   <NA>      aU       k   p6de
#> 3         28    ountuhko  aUnt6ko   <NA>      aU       n   t6ko
#> 4         21     owptudd   aUpt6d   <NA>      aU       p    t6d
#> 5         18      baydag   bedaeg    bed      ae       g   <NA>
#> 6          9    boduhyow  bod6jaU   bod6       j      aU   <NA>
#> 7          2      bogeeb    bogib     bo       g       i      b
#> 8         33    boofkeet   bufkit     bu       f       k     it
#> 9         43    degdinay  dEgd6ne     dE       g       d    6ne
#> 10        35    doagdate   dogdet     do       g       d     et
#> # ... with 81 more rows, and 8 more variables: TP3_AudioFileAAE <chr>,
#> #   TP3_AudioFileSAE <chr>, TargetStructure <chr>, Frequency <chr>,
#> #   ComparisonPair <chr>, TP2_AudioFileAAE <chr>, TP2_AudioFileSAE <chr>,
#> #   LexFreq <chr>
#> 
#> 
#> $CustomLists
#> $CustomLists$RealWordRep_003L53FS5
#> # A tibble: 132 × 9
#>      Word WorldBet TargetC TargetV Frame ComparisonPair           Block
#>     <chr>    <chr>   <chr>   <chr> <chr>          <chr>           <chr>
#> 1  shorts    Sorts       S      or    ts           <NA> Familiarization
#> 2    girl     g3rl       g      3r     l           <NA> Familiarization
#> 3    cold     kold       k       o    ld           <NA> Familiarization
#> 4     cow      kaU       k      aU  <NA>           <NA> Familiarization
#> 5    cake      kek       k       e     k           <NA>          block1
#> 6    cake      kek       k       e     k           <NA>          block3
#> 7     cat     kaet       k      ae     t           <NA>          block2
#> 8  coffee     kafi       k       a    fi           <NA>          block2
#> 9   chair     tSEr      tS      Er  <NA>           <NA>          block2
#> 10 cheese     tSiz      tS       i     z           <NA>          block2
#> # ... with 122 more rows, and 2 more variables: AAEsoundFile <chr>,
#> #   Abbreviation <chr>
```

Test data coverage
------------------

We created our WordList tables using an incrementally developed suite of R scripts. These original WordList tables are used to validate the behavior of this package by comparing the original tables against the ones generated by this package. These tests are in the `tests` folder.

The testing data was selected to use all available combinations of dialect, experiment name (i.e., the name of the Eprime executable that generated the output), and trial counts among our collected data. The table belows shows each of the combinations of dialect, experiment name, and trial counts that are tested in this package.

| Task        | Study      | Dialect | ExperimentName                         |  NumTrials|
|:------------|:-----------|:--------|:---------------------------------------|----------:|
| NonWordRep  | TimePoint1 | AAE     | AAE\_NonWordRep                        |         50|
| NonWordRep  | TimePoint1 | SAE     | SAE\_NonWordRep                        |         50|
| NonWordRep  | TimePoint2 | AAE     | AAE\_NonWordRep\_TP2                   |         74|
| NonWordRep  | TimePoint2 | SAE     | SAE\_NonWordRep\_TP2                   |         74|
| NonWordRep  | TimePoint3 | AAE     | AAE\_NonWordRep\_TP3                   |         76|
| NonWordRep  | TimePoint3 | SAE     | SAE\_NonWordRep\_TP3                   |         76|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_3-13-13     |        103|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_3-13-13     |         52|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_PartI       |         37|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP2         |         94|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.epsilon |        118|
| RealWordRep | CochlearV1 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.zeta    |        120|
| RealWordRep | CochlearV2 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP2         |         94|
| RealWordRep | CochlearV2 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.epsilon |        118|
| RealWordRep | CochlearV2 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.zeta    |        120|
| RealWordRep | TimePoint1 | AAE     | AAE\_RealWordRep                       |        103|
| RealWordRep | TimePoint1 | AAE     | AAE\_RealWordRep\_BLOCKED\_3-13-13     |        103|
| RealWordRep | TimePoint1 | SAE     | SAE\_RealWordRep                       |        103|
| RealWordRep | TimePoint1 | SAE     | SAE\_RealWordRep\_BLOCKED\_3-13-13     |        103|
| RealWordRep | TimePoint1 | SAE     | SAE\_RealWordRep\_Blocked\_FINAL       |        103|
| RealWordRep | TimePoint2 | AAE     | AAE\_RealWordRep\_BLOCKED\_TP2         |         94|
| RealWordRep | TimePoint2 | AAE     | AAE\_RealWordRep\_BLOCKED\_TP2         |         52|
| RealWordRep | TimePoint2 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP2         |         94|
| RealWordRep | TimePoint3 | AAE     | AAE\_RealWordRep\_BLOCKED\_TP3\_beta   |        118|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.beta    |        120|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.beta    |        119|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.epsilon |        118|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.epsilon |          5|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.gamma   |        118|
| RealWordRep | TimePoint3 | SAE     | SAE\_RealWordRep\_BLOCKED\_TP3.zeta    |        120|

The build status badge at the top of this page indicates whether the package successfully passed all these tests (and also passed the standard checks for R packages).
