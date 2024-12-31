/*Logistic regression analysis for shipping data
Obserserved variables: ID, Warehouse_block, Mode_of_Shipment, Customer_care_calls, Customer_rating, Cost_of_the_Product, Prior_purchases, Product_importance, Gender, Discount_offered, Weight_in_gms.
Reached.on.Time_Y.N is the response variable*/

*Import data from file;
proc import datafile="shipping.csv" out=Shipping replace;
delimiter=',';
getnames=yes;
run;
Title "Shipping Data";
proc print;
run;

*Create dummy variables;
title "Create New Dummy Variables";
data Shipping_new;
set Shipping;
drop ID;
d_WH_block_A = (Warehouse_block = 'A');
d_WH_block_B = (Warehouse_block = 'B'); 
d_WH_block_C = (Warehouse_block = 'C'); 
d_WH_block_D = (Warehouse_block = 'D'); 
d_WH_block_E = (Warehouse_block = 'E'); 
d_WH_block_F = (Warehouse_block = 'F');
d_MS_Ship = (Mode_of_Shipment = 'Ship'); 
d_MS_Flight = (Mode_of_Shipment = 'Flight'); 
d_MS_Road = (Mode_of_Shipment = 'Road');
d_rating_1 = (Customer_rating = 1); 
d_rating_2 = (Customer_rating = 2); 
d_rating_3 = (Customer_rating = 3); 
d_rating_4 = (Customer_rating = 4); 
d_rating_5 = (Customer_rating = 5);
d_prod_imp_low = (Product_importance = 'low'); 
d_prod_imp_medium = (Product_importance = 'medium'); 
d_prod_imp_high = (Product_importance = 'high');
d_Gender = (Gender= "M");
run;
proc print;
run;

*Creates frequency table for the variable Reached_on_Time_Y_N; 
title "Frequency Table";
Proc freq;
Tables Reached_on_Time_Y_N;
Run;

*Descriptives;
TITLE "Descriptives";
PROC MEANS min P25 median P75 max;
VAR Customer_care_calls Cost_of_the_Product Prior_purchases Discount_offered Weight_in_gms;
RUN;

*Create boxplots;
title "Boxplot for Reached_on_Time_Y_N by Mode_of_Shipment";
proc sort;
by Mode_of_Shipment;
proc boxplot;
plot Reached_on_Time_Y_N * Mode_of_Shipment;
run;

title "Boxplot for Reached_on_Time_Y_N by Product_importance ";
proc sort;
by Product_importance;
proc boxplot;
plot Reached_on_Time_Y_N * Product_importance;
run;

*Fit logistic regression model with standardized coefficients and Diagnostics;
TITLE "Full Model with standardized coefficients and Diagnostics";
Proc logistic data=shipping_new;
Model Reached_on_Time_Y_N (event='1') = d_WH_block_A d_WH_block_B d_WH_block_C d_WH_block_D d_WH_block_E d_WH_block_F d_MS_Ship d_MS_Flight d_MS_Road 
Customer_care_calls d_rating_1 d_rating_2 d_rating_3 d_rating_4 d_rating_5 Cost_of_the_Product Prior_purchases d_prod_imp_low d_prod_imp_medium 
d_prod_imp_high d_Gender Discount_offered Weight_in_gms / rsq stb corrb influence iplots; 
Run;


*Remove outliers and influential observatons;
Data shipping_new2;
Set shipping_new;
If _n_ in (2299, 2490, 4199, 2030, 7274, 1302, 2028, 2104, 3740, 10541, 10595, 10844, 2321, 1440, 6245, 9426, 9500, 2514, 
			9248, 5500, 7316, 4596, 10617, 4808, 10602, 5531, 2245, 7005, 10903, 4646, 2187, 4773, 5942, 7684, 8892, 2466, 9145, 9774, 570, 
			7660, 5606, 4720, 10285, 6196, 7642, 551, 9277, 2540, 7621, 10727, 8865, 5593, 6169, 4760, 628, 1349, 9276, 7593, 5444) then delete;
Run;

*Fit logistic regression model without outliers and influential points;
TITLE "Full Model without outliers and influential points";
Proc logistic data=shipping_new2;
Model Reached_on_Time_Y_N (event='1') = d_WH_block_A d_WH_block_B d_WH_block_C d_WH_block_D d_WH_block_E d_WH_block_F d_MS_Ship d_MS_Flight d_MS_Road 
Customer_care_calls d_rating_1 d_rating_2 d_rating_3 d_rating_4 d_rating_5 Cost_of_the_Product Prior_purchases d_prod_imp_low d_prod_imp_medium 
d_prod_imp_high d_Gender Discount_offered Weight_in_gms / rsq; 
Run;



* Split the data into training and test sets - 70/30;
* samprate = 70% of observations to be randomly selected for training set
* out = train defines new sas dataset for training/test sets;
TITLE "Split the data into training and test sets - 70/30";
proc surveyselect data = shipping_new2 out = trainTest seed = 7775559 samprate = 0.70 outall;
run;
proc print data = trainTest;
run;

* new_y variable - indiate that it is part of training set;
* assign existing Y variable vaulue to new_y for training set;
TITLE "Assign existing Y variable vaulue to new_y for training set";
data trainTest;
set trainTest;
if(selected = 1) then new_y = Reached_on_Time_Y_N;
run;
proc print;
run;

*Model selection method stepwise using training set;
TITLE "Model selection using training set";
proc logistic;
Model new_y (event='1') = d_WH_block_A d_WH_block_B d_WH_block_C d_WH_block_D d_WH_block_E d_WH_block_F d_MS_Ship d_MS_Flight d_MS_Road Customer_care_calls d_rating_1 
d_rating_2 d_rating_3 d_rating_4 d_rating_5 Cost_of_the_Product Prior_purchases d_prod_imp_low d_prod_imp_medium d_prod_imp_high d_Gender Discount_offered Weight_in_gms 
/ selection = stepwise rsq;
run;

*Model selection method backward using training set;
TITLE "Model selection using training set";
proc logistic;
Model new_y (event='1') = d_WH_block_A d_WH_block_B d_WH_block_C d_WH_block_D d_WH_block_E d_WH_block_F d_MS_Ship d_MS_Flight d_MS_Road Customer_care_calls d_rating_1 
d_rating_2 d_rating_3 d_rating_4 d_rating_5 Cost_of_the_Product Prior_purchases d_prod_imp_low d_prod_imp_medium d_prod_imp_high d_Gender Discount_offered Weight_in_gms 
/ selection = backward rsq;
run;

************Final model fit for stepwise selection*****************************

*Fit final model with Diagnostics;
TITLE "Final Model with Diagnostics";
Proc logistic;
Model new_y (event='1') = Customer_care_calls d_rating_3 Cost_of_the_Product Prior_purchases 
d_prod_imp_high Discount_offered Weight_in_gms / rsq corrb influence iplots;
Run;

*Remove outliers and influential observatons;
Data trainTest_new;
Set trainTest;
If _n_ in (4022, 584, 2091, 10916, 1519, 231, 5029, 10771, 266, 4341, 2247, 10082, 7701, 8916, 6497,
10929, 5557, 10829, 1646, 4165, 9053, 1671, 9036, 1767, 5982, 10167, 6986, 5684, 4325, 710, 4545,4676,
9039, 10131, 910, 855, 1718, 2470, 10676, 10129, 4463, 4151, 4665, 8798, 9163, 141, 221, 8996, 127, 9480,
3899, 9398, 5470, 7246, 9712, 5496, 867, 3959) then delete;
Run;

* Rerun the final model after removing influential points;
TITLE "Final model after removing influential points";
Proc logistic;
Model new_y (event='1') = Customer_care_calls d_rating_3 Cost_of_the_Product Prior_purchases 
d_prod_imp_high Discount_offered Weight_in_gms/ rsquare;
Run;

* Rerun the final model after removing insignificant predictor Cost_of_the_Product;
TITLE "Final model after removing insignificant predictor Cost_of_the_Product";
Proc logistic;
Model new_y (event='1') = Customer_care_calls d_rating_3 Prior_purchases 
d_prod_imp_high Discount_offered Weight_in_gms/ rsquare;
Run;


*Compute prediction for customer_care_calls 1 and customer_care_calls 3 with product importance high and product importance low;
TITLE "Compute prediction for customer_care_calls 1 and customer_care_calls 3 with product importance high and product importance low";
Data new;
Input Customer_care_calls d_rating_3 Prior_purchases d_prod_imp_high Discount_offered Weight_in_gms; 
Datalines;
1 0 0 1 0 0
3 0 0 1 0 0
1 0 0 0 0 0
3 0 0 0 0 0
;
Run;
Proc print;
Run;

*Merge prediction dataset with original dataset;
TITLE "Merge prediction dataset with original dataset";
Data prediction;
Set new trainTest_new; 
Run;
Proc print;
Run;

*Run prediction;
TITLE "Run prediction";
Proc logistic data = prediction;
Model new_y (event='1') = Customer_care_calls d_rating_3 Prior_purchases 
d_prod_imp_high Discount_offered Weight_in_gms/ rsquare; 
Output out = pred_1 p=phat lower = lcl upper = ucl;
Run;
Proc print;
Run;

*Print predicted probabilities and confidence intervals;
TITLE "Print predicted probabilities and confidence intervals"; 
Proc print data = pred_1;
Run;


*3- steps;
*1 - run the final model;
*2- generate classification table to identify the threshold;
*3 - compute the predicted probability for Test set;
TITLE "Classification table to identify the threshold"; 
proc logistic data= trainTest_new;
model new_y (event='1')= Customer_care_calls d_rating_3 Prior_purchases 
d_prod_imp_high Discount_offered Weight_in_gms/ ctable pprob = (0.1 to 0.8 by 0.05);

* step 3;
output out = pred_2 (where = (new_y = . )) p = phat;
run;

*Compute predicted Y and generate the confusion matrix;
*Compute predicted Y;
TITLE "Compute predicted Y"; 
data probs;
set pred_2;
if (phat > 0.65) then pred_y = 1;
else
	pred_y = 0;
run;

proc print data = probs;
run;

* generate the confusion matrix;
TITLE "Confusion matrix"; 
proc freq data = probs;
tables Reached_on_Time_Y_N *pred_y / norow nocol nopercent;
run;

*************************************************************************************************************************************************************************
************Final model fit for Backward selection*****************************

*Fit final model with Diagnostics;
TITLE "Final Model with Diagnostics";
Proc logistic data trainTest;
Model new_y (event='1') = Customer_care_calls d_rating_2 Cost_of_the_Product Prior_purchases 
d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms / rsq corrb influence iplots;
Run;

*Remove outliers and influential observatons;
Data trainTest_new;
Set trainTest;
If _n_ in (4463, 4665, 3899, 9053, 1646, 5470, 4165, 867, 1671, 1767, 5982, 10167, 9480, 10771, 7701, 231, 4022, 6986,
10929, 9712, 8916, 9036, 4341, 10916, 5684, 4325, 5557, 10082, 10829, 2603, 3635, 5455, 10131, 221, 9561, 127, 10676, 
1231, 5496, 4016, 10129, 8798, 3959, 9163, 9398, 2091, 910, 1519, 1718, 584, 6497, 2470, 7246, 5029, 141, 266, 2247, 9039) then delete;
Run;

* Rerun the final model after removing influential points;
TITLE "Final model after removing influential points";
Proc logistic;
Model new_y (event='1') = Customer_care_calls d_rating_2 Cost_of_the_Product Prior_purchases 
d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms/ rsquare;
Run;

* Rerun the final model after removing insignificant predictor Cost_of_the_Product;
TITLE "Final model after removing insignificant predictor Cost_of_the_Product";
Proc logistic;
Model new_y (event='1') = Customer_care_calls d_rating_2 Prior_purchases 
d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms/ rsquare;
Run;


*Compute prediction for customer_care_calls 1 and customer_care_calls 3 with product importance high and product importance low;
TITLE "Compute prediction for customer_care_calls 1 and customer_care_calls 3 with product importance high and product importance low";
Data new;
Input Customer_care_calls d_rating_2 Prior_purchases d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms; 
Datalines;
1 0 0 0 0 0 0
3 0 0 0 0 0 0
1 0 0 1 0 0 0
3 0 0 1 0 0 0
;
Run;
Proc print;
Run;

*Merge prediction dataset with original dataset;
TITLE "Merge prediction dataset with original dataset";
Data prediction;
Set new trainTest_new; 
Run;
Proc print;
Run;

*Run prediction;
TITLE "Run prediction";
Proc logistic data = prediction;
Model new_y (event='1') = Customer_care_calls d_rating_2 Prior_purchases 
d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms/ rsquare; 
Output out = pred_1 p=phat lower = lcl upper = ucl;
Run;
Proc print;
Run;

*Print predicted probabilities and confidence intervals;
TITLE "Print predicted probabilities and confidence intervals"; 
Proc print data = pred_1;
Run;


*3- steps;
*1 - run the final model;
*2- generate classification table to identify the threshold;
*3 - compute the predicted probability for Test set;
TITLE "Classification table to identify the threshold"; 
proc logistic data= trainTest_new;
model new_y (event='1')= Customer_care_calls d_rating_2 Prior_purchases 
d_prod_imp_low d_prod_imp_medium Discount_offered Weight_in_gms/ ctable pprob = (0.1 to 0.8 by 0.05);

* step 3;
output out = pred_2 (where = (new_y = . )) p = phat;
run;

*Compute predicted Y and generate the confusion matrix;
*Compute predicted Y;
TITLE "Compute predicted Y"; 
data probs;
set pred_2;
if (phat > 0.65) then pred_y = 1;
else
	pred_y = 0;
run;

proc print data = probs;
run;

* generate the confusion matrix;
TITLE "Confusion matrix"; 
proc freq data = probs;
tables Reached_on_Time_Y_N *pred_y / norow nocol nopercent;
run;




