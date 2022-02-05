---
title: "20_preliminary_eda"
output: html_notebook
---

Here, I'll do just the smallest bit of EDA with an eye towards cleaning.  In this notebook, I basically aim to understand:
- Does there appear to be anything strange about the data?
- Are there any values so extreme that they seem like an error?
- How much of the data is missing?

To do this, I'll use one of my favorite workhorse packages, `DataExplorer`.

*Note: 10_load_data must be run prior to running this notebook.*

```{r import packages}
library(DataExplorer)
```

# Basic overview of data

```{r dataset overview}
all_data %>% plot_intro()
```
It looks like we've got a few categorical columns, but most are continuous.  No column has completely missing data, and all rows are 100% complete (no NAs).  There are no missing observations.

# How much of the data is missing?
```{r missing data, fig.height=8, fig.width=4}
all_data %>% plot_missing()
```
Ah.  As previously stated, there are no missing data here.

# Variable distributions
## Discrete (categorical) variables
Here, I'll take a look at the distribution of each variable by looking at their histograms.  We'll try to get a quick overview on whether things are weird.
```{r discrete variable distributions}
all_data %>% plot_bar()
```
This matches the values we have seen when we read the data in and combined it together.

## Continuous variables
```{r continuous variables, fig.height=12}
all_data %>% plot_histogram(nrow =11)
```
Some of these plots have extremely long tails.  I'd like to take a look at whether these are just an artifact of the way that they are plotted, or whether these are real values.  I'll take a look at `volume` to make sure.

```{r distribution of w_t_ratio}
all_data %>%
  select(volume) %>%
  arrange(desc(volume)) %>%
  slice(1:10)
```
OK.  So we know that these are real values.  We should check with the collaborator to understand these extreme values, given the distribution of these variables, but also the expected size of the microdebitage.  This volume is absolutely huge.

# Questions on microdebitage
- Should we remove microdebitage that is larger than some dimension?
- What's the differentiating quality of length and width?  They're the same measurement depending on orientation.
