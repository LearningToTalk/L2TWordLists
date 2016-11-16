library(dplyr)

## RealWordRep

rwr_tp1 <- readr::read_tsv("./data-raw/RealWordRepItems.txt")
rwr_tp2 <- readr::read_tsv("./data-raw/RealWordRepItems_TP2list.txt")

# Rename the TP3 columns to match the WordList output names
prep_tp3_list <- . %>%
  readr::read_tsv() %>%
  rename(Word = Orthography, TargetC = Target1,
         TargetV = Target2, Frame = Frame2)

rwr_tp3 <- prep_tp3_list("./data-raw/RealWordRepItems_TP3.txt")

# Custom RWR wordlists
rwr_tp3_003L <- "./data-raw/RealWordRepItems_TP3_RealWordRep_003L53FS5.txt" %>%
  prep_tp3_list %>%
  select(-Abbreviation) %>%
  rename(Abbreviation = Abbreviation120)

## NonWordRep lists

nwr_tp1 <- readr::read_tsv("./data-raw/NonWordRepetitionItems_TP1.txt")
nwr_tp2 <- readr::read_tsv("./data-raw/NonWordRepetitionItems_TP2.txt")
nwr_tp3 <- readr::read_tsv("./data-raw/NonWordRepetitionItems_TP3.txt")


# Create an external list (`l2t_wordlists`) and an internal copy
# (`int_l2t_wordlists`). The external one is accessible like anything else
# exported by the package. The internal one is used by the code inside the
# package. TJM resorted to creating the two versions because the R package
# checks warned about the use of a undefined global object when we tried using
# only the external list.
int_l2t_wordlists <- l2t_wordlists <- list(
  RealWordRep = list(
    TimePoint1 = rwr_tp1,
    TimePoint2 = rwr_tp2,
    TimePoint3 = rwr_tp3),
  NonWordRep = list(
    TimePoint1 = nwr_tp1,
    TimePoint2 = nwr_tp2,
    TimePoint3 = nwr_tp3),
  CustomLists = list(
    `RealWordRep_003L53FS5` = rwr_tp3_003L
  )
)

# external version
devtools::use_data(l2t_wordlists, overwrite = TRUE)
# package-internal version
devtools::use_data(int_l2t_wordlists, overwrite = TRUE, internal = TRUE)
