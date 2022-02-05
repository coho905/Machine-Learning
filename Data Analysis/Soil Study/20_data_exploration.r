---
title: "20_data_exploration"
output: html_document
---

# Explore Data Below

```{r data_check}
ArchaeologicalSoilData %>% head()
LithicExperimentalData %>% head()
```

```{r mean_area}
ArchaeologicalSoilData %>% 
  summarize(mean_Area = mean(Area, na.rm = TRUE))
```
