---
title: "10_data_load"
output: html_document
---

```{r library_load}
library(readr)
library(tidyverse)
library(janitor)
library(forcats)
```

# Read Data
```{r data_load}
# use 'Import Dataset' tool and copy paste from Code Preview
soil_data <- read_csv("ArchaeologicalSoilData.csv") %>%
  clean_names()
  

lithic_data <- read_csv("LithicExperimentalData.csv") %>%
  clean_names()
```


# Preview Data
Here, I'll get a quick overview of information about the data.  Here, I'm trying to get a basic understanding of the number of rows, the number of variables, what the variables are, and their data types.

# Soil samples
```{r data_check}
soil_data %>% glimpse()
```

Here, we've got 48 columns and about 34,000 rows.  Reading the column names with the included pdf, it looks like most of them make some sort of sense.  I've got some questions about the `filter` variables; not sure what's going on there, and also, the `hash` column appears to be constant.  Interesting.
## Experimental (Microdebitage) data
Now, let's glimpse the microdebitage data.
```{r microdebitage preview}
lithic_data %>% glimpse()
```
5,229 rows and the same 48 columns it looks like.  Same issues with `filter` and `hash` columns.

# Arrange the data
Now, we're going to put everything into a single dataframe.  We'll also add a column to the data regarding the type of the data.  We've abused the soil data just a little bit because it actually does contain some samples of lithic microdebitage, so all of the particles _will not_ be only soil.  However, the expected percentage here is <1%.
```{r combine datasets}
soil_data <- soil_data %>%
  mutate(particle_class = 'site')
lithic_data <- lithic_data %>%
  mutate(particle_class = 'exp')
all_data <- soil_data %>%
  bind_rows(lithic_data) %>%
  mutate(particle_class = fct_relevel(as_factor(particle_class), 'exp', 'site')) %>%
  select (particle_class, everything(), -starts_with('filter'), -hash)
all_data %>% glimpse()
```
This looks good.  About 42k rows and 48 + 1 (`particle_Class`) - 1 (`hash`) - 6 (`filter0-6`) = 41 columns.  We can check with the project PI to make sure the rest of the columns make sense.
