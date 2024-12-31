# Logistic Regression: Shipping Data
## Overview
This project leverages logistic regression to predict the likelihood of on-time shipment deliveries, addressing a binary classification problem. With a dataset of 10,999 records and 11 variables, the analysis identifies significant predictors influencing delivery performance.
## Key Features
- **Data Preparation**: Dropped non-contributory columns and created dummy variables for categorical data such as `Warehouse_block`, `Mode_of_Shipment`, and `Product_importance`.
- **Exploratory Analysis**: Conducted statistical analyses and visualized data distributions using frequency tables and boxplots.
- **Model Building**:
- Employed full model analysis and diagnostics, including multicollinearity checks, residual analysis, and influential point identification.
- Used stepwise and backward selection methods to refine models.
- **Model Evaluation**:
- Final model included 6 significant predictors with an R-squared value of 23.86%. - Achieved 66% accuracy, 93% precision, and 95% specificity in test performance.
## Results
- Key Predictors: `Customer_care_calls`, `Product_importance_high`, `Discount_offered`, and `Weight_in_gms`.
- Final Model Equation:
log(p/1-p) = 1.61 - 0.23(Customer_care_calls) + 0.16(d_rating_3)
• 0.08(Prior_purchases) + 0.33(d_prod_imp_high) + 0.11(Discount_offered)
• 0.00028(Weight_in_gms)
- Identified actionable insights, including the impact of discounts and customer care calls on timely delivery likelihood.
## Technologies Used
- **Programming Language:** SAS
- **Tools:** PROC LOGISTIC, PROC MEANS, PROC UNIVARIATE
- **Analysis Techniques:** Logistic Regression, Model Diagnostics, Predictive Analytics, Data Visualization
## Repository Contents
1. **SAS Code File (`Logistic Regression Analysis - Shipping data.sas`)**  
   - This file contains the complete SAS code used for data preprocessing, logistic regression model building, and diagnostics.  

2. **Project Presentation (`Logistic Regression_ Shipping Data-.pdf`)**  
   - A concise slide deck summarizing the project’s objectives, methodology, key findings, and insights.  

3. **Project Report (`Project Report.pdf`)**  
   - A detailed document explaining the project, including data analysis, model evaluation, and recommendations.  

