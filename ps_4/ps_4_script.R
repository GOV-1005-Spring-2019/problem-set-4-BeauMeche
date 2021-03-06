library(tidyverse)
library(readr)
library(gt)
library(devtools)
library(lubridate)


poll <- read_csv(file = "ps_4_elections-poll-nc09-3.csv")

#Question 1
W <- poll %>%
  group_by(response) %>%
  count() %>%
  spread(response, n)

# ML #1: dem voters
dems <- W %>%
  pull(Dem)

#ML #2: republicans more than undecideds
ML2 <- W %>%
  pull(Rep-Und)

#ML #3: number of gender that didnt match gender combined
ML3 <- poll %>%
  filter(gender != gender_combined) %>%
  count() %>% pull (n)

#ML #4: race column discrepancies
ML4 <- poll %>%
  select(race_eth, file_race_black) %>%
  filter(race_eth == "White" &
         file_race_black != "White") %>%
  count() %>% pull(n)

#ML #5: fastest Rep vs. fastest Dem
ML5 <- poll %>%
  filter(response == "Dem" | response == "Rep") %>%
  group_by(response) %>%
  summarize(time = min(timestamp)) %>%
  spread(response, time) %>%
  mutate(diff = round(Rep - Dem, 0)) %>%
  select(diff)
  
#Quesion 2
chart <- poll %>%
  select(response, race_eth, final_weight) %>%
  filter(race_eth != "[DO NOT READ] Don't know/Refused") %>%
  mutate(race_eth = fct_relevel(race_eth, c("White", "Black", "Hispanic", "Asian", "Other")))%>%
  group_by(race_eth, response) %>%
  summarize(total = sum(final_weight)) %>%
  spread(key = response, value = total, fill = 0) %>%
  ungroup()

chart %>%
  mutate(all = Dem+Rep+Und+`3`)%>%
  mutate(Dem = Dem/all) %>%
  mutate(Rep = Rep/all) %>%
  mutate(Und = Und/all) %>%
  select(-all, -`3`) %>%
  ungroup() %>%
  na_if(0) %>%
  gt() %>%
  fmt_percent(columns = vars(Dem, Rep, Und), decimals = 0) %>%
  tab_header(
    title = ("Demographic Polling Results in N.C. 9")) %>%
  tab_source_note(source_note = "Data from the 3rd wave for North Carolina's 9th Congressional District") %>%
  cols_label(
    race_eth = "",
    Dem = "DEM.",
    Rep = "REP.",
    Und = "UND.")

