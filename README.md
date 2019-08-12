# Likelihood Ratio Test MACRO for the Stratified Cox Proportional Hazard Model

For SAS® users, there is no way to automatically request the likelihood ratio
test as an output when looking at two stratified Cox Proportional Hazard
models. Instead, this requires two PROCs and a few data steps. We created a
SAS® MACRO to make this coding more efficient and allow the user to obtain
parameter estimates for both the likelihood ratio test statistic and its
corresponding p-value. Below explains how the use of this SAS® MACRO aids users
in choosing between the interaction and no-interaction stratified Cox
Proportional Hazard models. 

## Usage

1. [Parameters](#parameters)
1. [Examples](#examples)
  
### Parameters

Our SAS® MACRO has seven parameters to be defined by the user:

```
data             = The data set name
time_var         = The event time variable
censor_var       = The censoring indicator variable
censor_vals      = The value(s) for censored individuals
strata_vars      = The stratifying variable (MUST BE CATEGORICAL)
quant_covariates = The names of numeric covariates in the model
class_covariates = The names of categorical covariates in the model
class_opts       = Options for the class statement in PROC PHREG
```

### Examples

**TODO**

## Documentation

A detailed explanation of usage and the underlying computational steps can be
found in our [MWSUG paper](https://example.com/mypaper.pdf).