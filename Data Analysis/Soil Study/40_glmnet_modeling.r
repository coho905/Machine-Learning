---
title: "40_glmnet_modeling"
output: html_notebook
---

In this notebook, we'll model using glmnet.

*Note that notebooks 10, 20, and 30 must first be run.*
In the previous notebooks, we've assembled the data and created a general recipe.  Here, we can create a more specific recipe for our glmnet model.  We'll also perform the rest of the modeling steps.

```{r library functions}
library(tidymodels)
library(glmnet)
library(tictoc)
```

# Build and test a fully specified model using cross validation

Here, I'll specify the penalty and mixture components of a glmnet. We'll fit this particular model and evaluate the performance using cross validation.

```{r glmnet recipe}
glmnet_recipe <- general_recipe %>%
  step_normalize(all_predictors(), -all_nominal())
```

```{r define glmnet workflow}
glmnet_spec <- 
  logistic_reg(penalty = 0.00002, mixture = 0.3) %>% 
  set_mode("classification") %>% 
  set_engine("glmnet") 
glmnet_workflow <- 
  workflow() %>% 
  add_recipe(glmnet_recipe) %>% 
  add_model(glmnet_spec) 
glmnet_workflow
```

In the following step, we fit models on all of the resamples and evaluate their performance.
```{r fit using cross validation}
glmnet_res_fits <- glmnet_workflow %>%
  fit_resamples(cv_folds)
glmnet_res_fits
```

We can look at the individual performance...
```{r}
glmnet_res_fits %>%
  select(id, .metrics) %>%
  unnest(.metrics)
```

And look at the overall performance of this model.  Not bad, it seems, at least on the training set.  Let's actually fit the model and see the performance on the test set.
```{r}
collect_metrics(glmnet_res_fits)
```
Let's do a fit on the training data.
```{r}
glmnet_fit <- glmnet_workflow %>%
  fit(data=train_data)
```

Let's look at the performance on the training data.
```{r}
training_preds <- 
  predict(glmnet_fit, train_data) %>%
  bind_cols(predict(glmnet_fit, train_data, type = "prob")) %>% 
  bind_cols(train_data %>% 
              select(particle_class))
training_preds
```

```{r}
training_preds %>%
  conf_mat(particle_class, .pred_class) %>%
  autoplot(type='heatmap')
```

```{r}
testing_preds <- 
  predict(glmnet_fit, test_data) %>%
  bind_cols(predict(glmnet_fit, test_data, type = "prob")) %>% 
  bind_cols(test_data %>% 
              select(particle_class))
testing_preds %>%
  conf_mat(particle_class, .pred_class) %>%
  autoplot(type='heatmap')
```

# Determine best tuning parameters using cross validation

First, we'll update the workflow with variable parameters that should be tuned.
```{r}
tune_spec <- 
  logistic_reg(penalty = tune(), mixture = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("glmnet") 
tune_workflow <- workflow() %>%
  add_recipe(glmnet_recipe) %>%
  add_model(tune_spec)
tune_workflow
```

Next, we'll create a set of parameters to iterate over. Each model will be built and cross-validated.
```{r define glmnet grid for parameter search}
glmnet_params <- parameters(tune_spec) 
glmnet_params
glmnet_grid <- tidyr::crossing(penalty = 10^seq(-3, -1, length.out = 2), mixture = c(0.05, 0.8, 1))
glmnet_grid
```

Now, we'll find the best hyperparameters via tuning.
```{r}
tic()
glmnet_tune <- tune_grid( object = tune_workflow,
  resamples = cv_folds,
  metrics = metric_set(accuracy, roc_auc, pr_auc, sens, yardstick::spec, ppv, npv, f_meas),
  grid = glmnet_grid,
  control = control_grid(verbose=TRUE))
toc()
```

Now, as before, we can collect the metrics and see how each model did over all of the folds and all of the metrics.
```{r}
glmnet_tune %>% collect_metrics()
```


We can then select the "best" model according to some metric.

```{r}
glmnet_tune %>% show_best('roc_auc')
best_glmnet_params <- glmnet_tune %>%
  select_best('roc_auc')
best_glmnet_params
```

## Final fit
Now, we can actually select the best hyperparameters and create the final fit on all of the training data:

```{r}
glmnet_final_wf <- tune_workflow %>%
  finalize_workflow(best_glmnet_params)
glmnet_final_wf
glmnet_final_fit <- glmnet_final_wf %>%
  fit(data = train_data)
```

## Performance Evaluation
Let's look at the performance on the training data.
```{r}
hp_training_preds <- 
  predict(glmnet_final_fit, train_data) %>%
  bind_cols(predict(glmnet_final_fit, train_data, type = "prob")) %>% 
  bind_cols(train_data %>% 
              select(particle_class))
hp_training_preds %>%
  conf_mat(particle_class, .pred_class) %>%
  autoplot(type='heatmap')
```


Let's look at the performance on the testing data.
```{r}
hp_testing_preds <- 
  predict(glmnet_final_fit, test_data) %>%
  bind_cols(predict(glmnet_final_fit, test_data, type = "prob")) %>% 
  bind_cols(test_data %>% 
              select(particle_class))
hp_testing_preds %>%
  conf_mat(particle_class, .pred_class) %>%
  autoplot(type='heatmap')
```

# On Metrics
There are many metrics that can be computed on the performance of a model.  These functions use the `yardstick` package, so make sure to check out all of the measurement functions contained in the package!

```{r}
sens(hp_testing_preds, particle_class, .pred_class)
spec(hp_testing_preds, particle_class, .pred_class)
```
