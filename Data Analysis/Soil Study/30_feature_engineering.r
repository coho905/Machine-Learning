---
title: "30_feature_engineering"
output: html_notebook
---

In this notebook, we start to code up some of the feature engineering steps of tidymodels.  We'll import tidymodels here.

```{r library imports}
library(tidymodels)
library(usemodels)
```

# Here, we can use usemodels to guess the feature engineering steps that we'll do.
```{r generate usemodels template}
use_glmnet(particle_class ~ ., data = all_data)
```

# Split the data
```{r ml data split}
set.seed(2434)
data_split <- initial_split(all_data, prop=3/4, strata=particle_class)
train_data <- training(data_split)
test_data <- testing(data_split)
```

# Add cross-validation splits for tuning
```{r}
cv_folds <- vfold_cv(train_data, v=5, strata=particle_class)
cv_folds
```


# Add usemodels recipe
```{r general recipe}
general_recipe <- 
  recipe(formula = particle_class ~ ., data = train_data) %>% 
  update_role(id, img_id, new_role='no_model') %>%
  step_zv(all_predictors())
summary(general_recipe)
```
