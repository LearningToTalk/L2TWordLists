library(dplyr)


# sae_experiments <- data_frame(
#   Experiment = c(
#     "SAE_RealWordRep_BLOCKED_TP3.beta",
#     "SAE_RealWordRep_BLOCKED_TP3.epsilon",
#     "SAE_RealWordRep_BLOCKED_TP3.gamma",
#     "SAE_RealWordRep_BLOCKED_TP3.zeta"),
#   Dialect = "SAE"
# )


rwr_tp1 <- readr::read_tsv("./data-raw/RealWordRepItems.txt")
rwr_tp2 <- readr::read_tsv("./data-raw/RealWordRepItems_TP2list.txt")

prep_tp3_list <- . %>%
  readr::read_tsv() %>%
  rename(Word = Orthography, TargetC = Target1,
         TargetV = Target2, Frame = Frame2)

rwr_tp3 <- prep_tp3_list("./data-raw/RealWordRepItems_TP3.txt")

# Custom wordlists
rwr_tp3_003L <- "./data-raw/RealWordRepItems_TP3_RealWordRep_003L53FS5.txt" %>%
  prep_tp3_list %>%
  select(-Abbreviation) %>%
  rename(Abbreviation = Abbreviation120)

int_l2t_wordlists <- l2t_wordlists <- list(
  RWR = list(
    TimePoint1 = rwr_tp1,
    TimePoint2 = rwr_tp2,
    TimePoint3 = rwr_tp3),
  CustomLists = list(
    `RealWordRep_003L53FS5` = rwr_tp3_003L
  )
)

# external version
devtools::use_data(l2t_wordlists, overwrite = TRUE)
# package-internal version
devtools::use_data(int_l2t_wordlists, overwrite = TRUE, internal = TRUE)
