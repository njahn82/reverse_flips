


### Elsevier check


```r
library(tidyverse)
```

using spreadsheet data extracted from pdfs using tabula


```r
apc_current <- readr::read_csv("data/tabula-j.custom97.csv") %>%
  filter(!`OA Model` %in% c("OA Model")) %>%
  mutate(Price = as.numeric(Price))
apc_2016 <- readr::read_csv("data/tabula-j.custom97_2016_elsevier.csv") 
```

Create a data frame with flipped journals by journal title and issn


```r
bind_rows(apc_current, apc_2016) %>%
  distinct(`Journal Title`, ISSN, `OA Model`) %>%
  group_by(`Journal Title`, ISSN) %>%
  filter(!is.na(`OA Model`)) %>%
  filter(n() > 1) -> flipped_jns
```

Are there duplicate journals?


```r
flipped_jns %>%
  distinct(`Journal Title`, ISSN) %>%
  filter(n() > 1)
#> # A tibble: 0 x 2
#> # Groups:   Journal Title, ISSN [0]
#> # ... with 2 variables: ISSN <chr>, `Journal Title` <chr>
```

Which one has been flipped and breakdown by OA current OA Model


```r
apc_current %>% 
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>% 
  count(`OA Model`)
#> # A tibble: 2 x 2
#>   `OA Model`      n
#>   <chr>       <int>
#> 1 Hybrid         11
#> 2 Open Access    23
```

list reverse flip journals


```r
apc_current %>%
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>%
  filter(`OA Model` == "Hybrid")
#> # A tibble: 11 x 5
#>    ISSN      `Journal Title`                     `OA Model` Currency Price
#>    <chr>     <chr>                               <chr>      <chr>    <dbl>
#>  1 2352-2151 Agri Gene                           Hybrid     USD       1500
#>  2 2214-9996 Annals of Global Health             Hybrid     USD       1200
#>  3 1029-3132 Asia Pacific Management Review      Hybrid     USD          0
#>  4 1309-1042 Atmospheric Pollution Research      Hybrid     USD       1500
#>  5 2352-2143 Computational Condensed Matter      Hybrid     USD       1000
#>  6 1876-6102 Energy Procedia                     Hybrid     USD          0
#>  7 2215-1532 Environmental Nanotechnology, Moni… Hybrid     USD       1950
#>  8 1878-450X International Journal of Gastronom… Hybrid     USD       3000
#>  9 1369-7021 Materials Today                     Hybrid     USD       3300
#> 10 2214-5400 Meta Gene                           Hybrid     USD       1500
#> 11 2352-4073 Plant Gene                          Hybrid     USD       1500
```

save flipped journals


```r
apc_current %>% 
  filter(`Journal Title` %in% flipped_jns$`Journal Title`) %>%
  write_csv("data/elsevier_flipped.csv")
```

