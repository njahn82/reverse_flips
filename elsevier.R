#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE)
#' ### Elsevier check
library(tidyverse)
#' using spreadsheet data extracted from pdfs using tabula
apc_current <- readr::read_csv("data/tabula-j.custom97.csv") %>%
  filter(!`OA Model` %in% c("OA Model")) %>%
  mutate(Price = as.numeric(Price))
apc_2016 <- readr::read_csv("data/tabula-j.custom97_2016_elsevier.csv") 
#' Create a data frame with flipped journals by journal title and issn
bind_rows(apc_current, apc_2016) %>%
  distinct(`Journal Title`, ISSN, `OA Model`) %>%
  group_by(`Journal Title`, ISSN) %>%
  filter(!is.na(`OA Model`)) %>%
  filter(n() > 1) -> flipped_jns
#' Are there duplicate journals?
flipped_jns %>%
  distinct(`Journal Title`, ISSN) %>%
  filter(n() > 1)
#' Which one has been flipped and breakdown by OA current OA Model
apc_current %>% 
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>% 
  count(`OA Model`)
#' list reverse flip journals
apc_current %>%
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>%
  filter(`OA Model` == "Hybrid")
#' save flipped journals
apc_current %>% 
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>%
  write_csv("data/elsevier_flipped.csv")
