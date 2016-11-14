# library(dplyr)

rwr_tp1 <- readr::read_tsv("./data-raw/RealWordRepItems.txt")
rwr_tp2 <- readr::read_tsv("./data-raw/RealWordRepItems_TP2list.txt")
rwr_tp3 <- readr::read_tsv("./data-raw/RealWordRepItems_TP3.txt")

l2t_wordlists <- list(
  RWR = list(
    TimePoint1 = rwr_tp1,
    TimePoint2 = rwr_tp2,
    TimePoint3 = rwr_tp3)
)

devtools::use_data(l2t_wordlists, overwrite = TRUE)
