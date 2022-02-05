---
title: "Penguin-Analysis"
output: html_notebook
---

In this notebook, we analyze the Palmer Penguins dataset.  This will allows us to classify different penguin types based on physical characteristics.

# Load Packages

```{r load packages}
library(tidyverse)
library(palmerpenguins)

```

# View Data

This is the header 

```{r view data}
head(penguins)
```

Let's look at the data
This is a tibble
```{r view }
penguins
```
I only want to look at the Torgersen Penguins
```{r}
penguins%>%
  filter(island == "Torgersen")
```
# Investigating the data
What is the mean bill length of all penguins?
```{r}
penguins %>%
  summarise(bill_length_mean = mean(bill_length_mm, na.rm = TRUE))
```
Are the bill lengths different between island groups?
```{r}
penguins %>%
  group_by(island) %>%
  summarise(bill_length_mean = mean(bill_length_mm, na.rm = TRUE))
```
I want a reduced dataset. I don't need flipper length anymore.
```{r}
penguins %>%
  select(-flipper_length_mm)
```

Sophia says using just an exclamation works too
```{r}
penguins %>%
  select(!flipper_length_mm) %>%
  select(year, everything())
```

Mean Bill Length/Depth in inches
```{r}
penguins %>%
mutate(bill_length_in = bill_length_mm/25.4) %>%
mutate(bill_depth_in = bill_depth_mm/25.4) %>%
summarize(bill_length_mean = mean(bill_length_in, na.rm = TRUE), bill_depth_mean = mean(bill_depth_in, na.rm = TRUE))

```

## What is the relationship between flipper length and body mass
```{r scatter plot flipper length vs body mass}
penguins %>%
  ggplot(aes(x=flipper_length_mm, y = body_mass_g, color = species)) + 
  geom_point(na.rm = TRUE)
  
```
From this plot, we can see that there is a positive correlation between flipper length and body mass.  Also in general, the Gentoo penguins tend to be larger than the Adelie or Chinstrap.  The latter 2 species seem to be about the same general size.


## Flipper length vs bill length
```{r flipper vs bill length and gender}
penguins %>%
  ggplot(aes(x=flipper_length_mm, y = bill_length_mm, color = sex, shape = species)) + 
  geom_point(na.rm = TRUE)
```
The Chinstrap and Gentoo have similar sized bill lengths that are bigger than the Adelle. The Gentoo however have the largest flipper length with the Adelle and Chinstrap being similar in size. The males in each species are bigger than the females, but the females in bigger species are bigger than the males in a smaller species.

# Bar Graph
```{r Bar Graph}
penguins %>%
  ggplot(aes(sex)) + 
  geom_bar()
```
## Box Plot
```{r Box Plot}
penguins %>%
  drop_na(sex) %>%
  ggplot(aes(x=body_mass_g, y = sex)) + 
  geom_boxplot() + 
  geom_jitter(aes(x = body_mass_g, y = sex))
```

# Facet Wrap
```{r}
penguins %>%
  drop_na(sex) %>%
  ggplot(aes(x = body_mass_g, y = flipper_length_mm, color = sex)) +
  geom_point() +
  labs(title = "Penguins sizes by gender and island", 
       x = "body mass", 
       y = "flipper length", 
       subtitle = "differentiating penguins") +
  facet_wrap(facets = 'species')
```






The preview shows you a rendered HTML copy of the contents of the editor. Consequently, unlike *Knit*, *Preview* does not run any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.
