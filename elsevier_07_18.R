#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  fig.width = 6,
  fig.asp = 0.618,
  out.width = "70%",
  fig.align = "center")
#' # Does Elsevier's flip the open access business model of its journals?
#' 
#' ### Prepare data
library(tidyverse)
#' load lisas files
my_df <- readr::read_delim("data/elsevier_07_18.csv",col_names = FALSE, delim = ";") %>%
  select(issn = X1, journal_name = X2, oa_model = X3, apc = X4, file = X5) %>%
  mutate(year = str_extract(file, "\\d{4}$"))
#'
#' backup cleaned version
writexl::write_xlsx(my_df, "data/elsevier_07_18_cleaned.xlsx")
#' retrieve flipped journals, i.e. journals with more than one oa model over time
my_df %>%
  distinct(issn, oa_model) %>%
  filter(!is.na(oa_model)) %>%
  group_by(issn) %>%
  filter(n() > 1) -> flipped_jns
#' create a data dump of all flipped journals
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  readr::write_csv("data/elsevier_07_18_flipped.csv")
#' ##  Results
#' 
#' ### OA / reverse flips
#' 
#' Current Elsevier journals
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  filter(year == 2018) %>%
  ungroup() %>%
  count(oa_model) %>%
  knitr::kable()
#' ### Show reverse flips
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  filter(year == 2018) %>%
  filter(oa_model == "Hybrid") %>%
  knitr::kable()
#' ### Show OA flips
my_df %>%
  filter(issn %in% flipped_jns$issn) %>%
  arrange(journal_name, year) %>%
  group_by(issn) %>%
  slice(which.max(year)) %>%
  filter(year == 2018) %>%
  filter(oa_model == "Open Access") %>%
  knitr::kable()
#' ## Development of Elsevier Open Access Journal Portfolio by year
my_df %>% 
  group_by(year) %>%
  count(oa_model) %>%
  ggplot(aes(year, n, fill = oa_model)) +
  geom_bar(stat = "identity") +
  labs(title = "Development of Elsevier Open Access Journal Portfolio") +
  ylab("Number of Journals") +
  xlab("Year") +
  scale_fill_manual("OA Model", values = c("#009392", "#d0587e")) +
  theme_minimal()
  ggsave("elsevier_07_18.pdf", width = 6, height = 6 * 0.618, dpi = "retina")
#' Discontinued journals by open access business models
  my_df %>%
    arrange(journal_name, year) %>%
    group_by(issn) %>%
    slice(which.max(year)) %>%
    filter(year < 2018) %>%
    ungroup() %>%
    count(oa_model, year) %>%
    ggplot(aes(year, n, fill = oa_model)) +
    geom_bar(stat = "identity") +
    labs(title = "Discontinued titles in Elsevier's Open Access Journal Portfolio") +
    ylab("Number of Journals") +
    xlab("Year") +
    scale_fill_manual("OA Model", values = c("#009392", "#d0587e")) +
    theme_minimal()
  ggsave("elsevier_07_18_discontinued.pdf", width = 6, height = 6 * 0.618, dpi = "retina")
