# Likelihood Ratio Test MACRO for the Stratified Cox Proportional Hazards Model

For SAS® users, there is no way to automatically request the likelihood ratio
test as an output when looking at two stratified Cox Proportional Hazards
models. Instead, this requires two PROCs and a few data steps. We created a
SAS® MACRO to make this coding more efficient and allow the user to obtain
parameter estimates for both the likelihood ratio test statistic and its
corresponding p-value. Below explains how the use of this SAS® MACRO aids users
in choosing between the interaction and no-interaction stratified Cox
Proportional Hazards models. 

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

First you must run the `lrt_strat_cox_ph` MACRO definition in the source editor or using `%include`. Then run the MACRO call `%lrt_strat_cox_ph( )` with appropriate parameters specified for you dataset.

Here is an example usage with a dataset called [addicts](http://web1.sph.emory.edu/dkleinb/surv3.htm#data "Website to addicts data") , which has 238 heroin addicts as subjects and records their time in days from clinic entry until departure. Suppose we want to see how methadone dose, prison record, and clinic affect the hazard rate of time until departure for the subjects. If you were to check the assumptions for the Cox Proportional Hazards Model, the variable `clinic` is found to violate them, meaning `clinic` cannot be an independent variable in the model. In order to still incorporate `clinic` in the model, we can use the Stratified Cox Proportional Hazards Model and stratify by clinic. Once the dataset is imported into SAS you can run the following code:

```sas
%lrt_strat_cox_ph(
  data=addicts, 
  time_var=survt, 
  censor_var=status,
  censor_vals=0,
  strata_vars= clinic, 
  quant_covariates= dose ,
  class_covariates= prison, 
  class_opts= param=glm
);
```

This will generate the PROC PHREG output tables for both the interaction and no-interaction stratified Cox Proportional Hazards models as well as a printout of the likelihood ratio test parameters and results. The table of results from this example is included below.

```
=================================================================================
    Stratified Cox Proportional Hazards Model Likelihood Ratio Test              
                        Summary of results                                       
---------------------------------------------------------------------------------
      -2LogLikelihood of the Reduced Model    =                         1195.43  
      -2LogLikelihood of the Full Model       =                         1193.56  
      Degrees of Freedom of the Reduced Model =                               2  
      Degrees of Freedom of the Full Model    =                               4  
      Model Degrees of Freedom                =                               2  
      Difference                              =                            1.87  
      Chi-Square p-value                      =                          0.3925  
=================================================================================
```


## Documentation

A detailed explanation of usage and the underlying computational steps can be
found in our [MWSUG paper](https://example.com/mypaper.pdf) (coming soon!).
