# Customer Churn & Retention Analysis

## 1. Executive Summary
This analysis investigates customer drop-off, subscription health, and support metrics across a 500-user dataset to identify key drivers of churn and quantify the financial impact.

**Key Findings:**
- **High Churn & Revenue Impact:** The current churn rate sits at 32.8%, leaving a retention rate of 67.2%. This drop-off currently represents **$3,107.36** in revenue at risk.
- **The Escalation Pipeline:** There is a severe positive correlation (**0.88**) between customer support escalations and churn. With an overall escalation rate of 30.8% and an average of 0.74 complaints per user, support interactions are the primary bottleneck for retention.
- **Plan Vulnerability:** Basic plan subscribers are churning at the highest rate (36.87%), compared to Premium (30.12%) and Standard (30.96%) users.
- **Customer Baseline:** The average customer is 38 years old, has a tenure of 510 days, and yields an Average Revenue Per User (ARPU) of $19.37.

**Strategic Takeaway:**
Immediate intervention is required in the customer support escalation process. Because escalations are nearly perfectly correlated with customers leaving, resolving tickets before they escalate is the single highest-leverage action the business can take to secure the $3,100+ in at-risk revenue.

## 2. Tech Stack
- **Database & Data Loading:** PostgreSQL via SQLAlchemy (`create_engine`)
- **Data Manipulation & Analysis:** Python (`pandas`, `numpy`)
- **Data Visualization:** Python (`matplotlib`, `seaborn`)

## 3. Data Cleaning & Preparation
Data was sourced from three primary tables (`db_customer`, `db_subscription`, `db_support`) and underwent significant cleaning:
- **Standardization:** Renamed the `name` column to `customer_name` and normalized `gender` entries (e.g., converting 'Men'/'Women' to 'Male'/'Female').
- **Date Formatting:** Converted string-based date columns (`dob`, `subscription_start_date`, `renewal_date`, `cancellation_date`, `complaint_date`) to standard datetime formats.
- **Missing Value Imputation:** 
  - Filled missing `state` values by mapping the first 3 digits of the `pincode` to a master state dictionary.
  - Filled missing `country` values by reverse-mapping from the populated `state` column.
- **Data Deduplication:** Grouped the support table by `customerid` to calculate total complaints and kept only the most recent complaint record per user to streamline correlation analysis.

## 4. Feature Engineering & Key Metrics
We created several new columns and calculated key business metrics to deepen our analysis:
- **Churn Flag:** Created a binary `churn_flag` (1 for churned, 0 for retained) based on the presence of a `cancellation_date`.
- **Customer Age:** Calculated `age` dynamically from the Date of Birth (`dob`) relative to the current date.
- **Tenure:** Computed `tenure_days` as the difference between the subscription start date and either the cancellation date (if churned) or today's date (if active).
- **Churn Risk Segmentation:** Categorized users into 'low', 'medium', and 'high' `churn_risk` based on their `churn_score`.
- **KPIs Calculated:**
  - **Churn Rate:** 32.8%
  - **Retention Rate:** 67.2%
  - **ARPU:** $19.37
  - **Revenue at Risk:** $3,107.36
  - **Average Customer Tenure:** 511 Days
  - **Escalation Rate:** 30.8%
  - **Correlation (Escalations vs. Churn):** 0.88

## 5. Merging Data
To perform a holistic analysis, we joined the cleaned `db_customer` table with `db_subscription` and `db_support` via `LEFT JOIN` on `customerid`, resulting in a master dataframe of 500 rows and 24 features.

## 6. Visualization
*(Visualizations generated via Matplotlib and Seaborn to track Monthly Churn Trends, Regional Revenue Distribution, and Churn Risk Segmentation)*
