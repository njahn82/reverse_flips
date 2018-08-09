#' Wiley
library(tidyverse)
my_df <- readxl::read_xlsx("wiley/journal_list.xlsx") %>%
  select(issn = ISSN, journal_name = `Journal Title`, oa_model =  `OA Model`, year = Year, File) %>%
  mutate(issn = toupper(issn)) %>%
  mutate(issn = gsub("\n", "", issn))
#' it seems that there are some issn variants per journal. Let's normalize issn information by using
#' the ISSN to ISSN-L matching list
issn_l <- readr::read_tsv("20180625.ISSN-to-ISSN-L.txt")
left_join(my_df, issn_l, by = c("issn" = "ISSN")) %>%
  mutate(issn = ifelse(!is.na(`ISSN-L`), `ISSN-L`, issn)) -> my_df
# check for name or issn changes
my_df %>%
  distinct(issn, oa_model) %>%
  filter(!is.na(oa_model)) %>%
  group_by(issn) %>%
  filter(n() > 1) -> flipped_jns
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  write_csv("wiley/flipped_jns.csv")
#' when did wiley flipped journals to fully OA?
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  filter(oa_model == "Hybrid") %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  mutate(year_flipped = as.integer(year) + 1) %>%
  ungroup() %>%
  count(year_flipped)
