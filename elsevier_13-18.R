#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  fig.width = 9,
  fig.height = 6)
#
library(tidyverse)
#' load lisa's file
my_df <- readxl::read_xlsx("data/elsevier_13-18.xlsx", col_types = "text")
#' number of files
my_df %>%
  distinct(File)
#' number of distinct journals
my_df %>%
  distinct(ISSN, `OA Model`) %>%
  filter(!is.na(`OA Model`)) %>%
  group_by(ISSN) %>%
  filter(n() > 1) -> flipped_jns
#' show flipped journals
my_df %>%
  filter(ISSN %in% flipped_jns$ISSN) %>% 
  select(1:5) %>%
  arrange(ISSN, File) %>%
  knitr::kable()
#' plot oa share in elsevier portfolio  
my_df %>%
  filter(!File == "Elsevier OA List 2013") %>% 
  filter(!`OA Model` == "OA Model") %>%
  group_by(File, `OA Model`) %>%
  summarise (n = n()) %>%
  mutate(freq = n / sum(n)) %>%
  ggplot(aes(File, freq, fill = `OA Model`)) + 
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::percent) 
#' table view
my_df %>%
  filter(!File == "Elsevier OA List 2013") %>% 
  filter(!`OA Model` == "OA Model") %>%
  group_by(File, `OA Model`) %>%
  summarise (n = n()) %>%
  mutate(freq = n / sum(n))
