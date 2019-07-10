/*****************************************************************************/
/*** Stratified Cox Proportional Hazards Model Likelihood Ratio Test Macro ***/
/*****************************************************************************/
/*                                                                           */
/* Authors: Rachel R. Baxter, B.S.; Katelyn J. Ware, B.A.;                   */
/*          Paul W. Egeler, M.S., GStat                                      */
/*                                                                           */
/* Required parameters:                                                      */
/*                                                                           */
/*  data             = The data set name                                     */
/*  time_var         = The event time variable                               */
/*  censor_var       = The censoring indicator variable                      */
/*  strata_vars      = The stratifying variable (MUST BE CATEGORICAL)        */
/*  quant_covariates = The names of numeric covariates in the model          */
/*  class_covariates = The names of class covariates in the model            */
/*  ref_value        = The reference value for the censoring variable        */
/*                                                                           */
/*****************************************************************************/

%macro lrt_strat_cox_ph(
  data             = /* The data set name                              */,
  time_var         = /* The event time variable                        */,
  censor_var       = /* The censoring indicator variable               */,
  strata_vars      = /* The stratifying variable (MUST BE CATEGORICAL) */,
  quant_covariates = /* The names of numeric covariates in the model   */,
  class_covariates = /* The names of class covariates in the model     */,
  ref_value      = 0 /* The reference value for the censoring variable */
  );

/* Local variables */
%local error interaction_i interaction_vars all_covariates;
%let error = 0;
%let all_covariates = &quant_covariates &class_covariates;
  
/* User Input Processing */
%if %sysfunc(countw(&strata_vars, %str( ))) ne 1 %then %do;
  %put ERROR: strata_vars requires exactly one variable;
  %let error = 1;
%end;

%if &error = 1 %then %goto finish;
  
/* Create all pairwise interactions between strata_vars and covariates */
%do interaction_i = 1 %to %sysfunc(countw(&all_covariates, %str( )));
  %let interaction_vars = &interaction_vars &strata_vars * %scan(&all_covariates,&interaction_i);
%end;

/* FULL MODEL */
proc phreg data=&data;
  class &class_covariates &strata_vars / param = glm;
  model &time_var*&censor_var(&ref_value) = &all_covariates &interaction_vars / type1;
  strata &strata_vars;
  ods output Type1 = lrt_strat_cox_ph_type1_full;  
run;

data  lrt_strat_cox_ph_type1_full (keep=neg2ll_full df_full);
  set lrt_strat_cox_ph_type1_full (rename=(Neg2LogLike=neg2ll_full)) end=last;
  retain df_full 0;
  df_full = sum(df_full, DF);
  if last;
run;

/* REDUCDED MODEL */
proc phreg data=&data;
  class &class_covariates &strata_vars / param = glm;
  model &time_var*&censor_var(&ref_value) = &all_covariates / type1;
  strata &strata_vars;
  ods output Type1 = lrt_strat_cox_ph_type1_red;    
run;

/* Final processing and output results */
data _null_;
  set lrt_strat_cox_ph_type1_red (rename=(Neg2LogLike=neg2ll_red)) end=last;
  retain df_red 0;
  df_red = sum(df_red, DF);
  if last then do;
    set lrt_strat_cox_ph_type1_full;
    diff   = neg2ll_red - neg2ll_full; 
    df     = df_full - df_red; 
    pvalue = 1-probchi(diff, df); 
    file print;
    HBAR1 = REPEAT("=",80);
    HBAR2 = REPEAT("-",80);
    put 
      HBAR1
    / @5 "Stratified Cox Proportional Hazards Model Likelihood Ratio Test"
    / @25 "Summary of results"
    / HBAR2
    / @7 "-2LogLikelihood of the Reduced Model    = " neg2ll_red  31.2
    / @7 "-2LogLikelihood of the Full Model       = " neg2ll_full 31.2
    / @7 "Degrees of Freedom of the Reduced Model = " df_red      31.
    / @7 "Degrees of Freedom of the Full Model    = " df_full     31.
    / @7 "Model Degrees of Freedom                = " DF          31.
    / @7 "Difference between -2LogL values        = " diff        31.2
    / @7 "Chi-Square p-value                      = " pvalue      31.4
    / HBAR1;
  end;
run;

/* Clean up datasets used in MACRO */
proc datasets lib=work memtype=data noprint;
  delete lrt_strat_cox_ph_type1_red lrt_strat_cox_ph_type1_full;
  quit;
run;

%finish:

%mend lrt_strat_cox_ph;
