# **Likelihood Ratio Test Macro for the Stratified Cox Proportional Hazard Model**

For SAS® users, there is no way to automatically request the likelihood ratio test as an output when looking at two stratified Cox Proportional Hazard models. Instead, this requires two procs and a few data steps. We created a SAS® macro to make this coding more efficient and allow the user to obtain parameter estimates for both the likelihood ratio test statistic and its corresponding p-value. Below explains how the use of this SAS® macro aids users in choosing between the interaction and no-interaction stratified Cox Proportional Hazard models. 

### **How to use the macro**

Overview of steps:

1. Defining Parameters
2. PROC PHREG
3. Data Steps
  
#### **Defining Parameters**
Our SAS® macro has seven parameters to be defined by the user:

-	*data =* the data set name
-	*time_var =* the event time variable
-	*censor_var =* the censoring indicator variable
-	*censor_vals =* the value(s) for censored individuals
-	*strata_vars =* the stratifying variable (the variable that does not meet the PH assumption)
    - Note: it **MUST** be **categorical**, so if it is quantitative, one must categorize it first
    - *At this point, our macro only supports one stratum variable, even though theoretically the*
    *stratified Cox PH model can include more than one stratum variable*.
- *quant_covariates =* the names of the numeric covariates in the model
-	*class_covariates =* the names of the categorical covariates in the model
-	*class_opts =* options for the class statement in PROC PHREG

#### **PROC PHREG**
The macro contains two uses of PROC PHREG, which use the supplied dataset and specified variables. As seen in the code snippet below, the macro variable *all_covariates* is created within the macro to include both the quantitative and categorical covariates specified by the user, and the local macro variable *interaction_vars* is initiated. A do loop is used to create all two-way interactions between each level of the stratum variable and each covariate.

```{SAS}
%local error interaction_i interaction_vars all_covariates
%let all_covariates = &quant_covariates &class_covariates

%do interaction_i = 1 %to %sysfunc(countw(&all_covariates, %str( )));
	%let interaction_vars = &interaction_vars
```

Each use of PROC PHREG contains an ods output statement which saves the Type1 test output to temporary datasets called lrt_strat_coxph_type1_full and lrt_strat_coxph_type1_red, respectively. These datasets contain the -2log*L* values from each model and the degrees of freedom (DF) associated with each. We are interested in the DF because each parameter in the full and reduced model is associated with 1 DF. In order to compute the DF for the likelihood ratio chi-square test, we need to know the difference in the number of parameters between each model. Thus, DF_full - DF_reduced = # Parameters in the full model - # Parameters in the reduced model. This is seen in the macro code below:

```{SAS}
proc phreg data=&data;
  class &class_covariates &strata_vars / &class_opts ;
  model &time_var*&censor_var(&censor_vals) = &all_covariates &interaction_vars / type1;
  strata &strata_vars;
  ods output Type1 = lrt_strat_cox_ph_type1_full;  
run;

proc phreg data=&data;
  class &class_covariates &strata_vars / &class_opts ;
  model &time_var*&censor_var(&censor_vals) = &all_covariates / type1;
  strata &strata_vars;
  ods output Type1 = lrt_strat_cox_ph_type1_red;    
run;
```

#### **Data Steps**
The first use of a data step in our macro sums the DF from the full model. The second data step sums the DF from the reduced model and then computes the difference between the -2Log*L* from each model (which is the test statistic), as well as the DF, and uses the `probchi()`function to generate the p-value of the likelihood ratio. 


