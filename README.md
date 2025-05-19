### Question 1: High-Value Customers with Multiple Products
Scenario:
The goal is to identify customers who have both a funded savings account and a funded plan, and rank them by total deposit amount. This is useful for identifying cross-selling opportunities among high-value customers.

##### My Approach
The SQL solution is structured in three main steps:

##### 1. Identify Funded Savings Accounts

In the savings_summary CTE, I filtered for accounts with amount > 0 to ensure we only consider active, funded savings.

I then grouped by owner_id to count how many savings accounts each user has and the total deposits across them.

##### 2. Identify Funded Plans

Similarly, in the plan_summary CTE, I filtered for plans with amount > 0 to ensure we only consider funded plans.

Grouping by owner_id allows us to count how many funded plans each user has.

##### 3. Join with the Users Table

I joined both summaries with the users_customuser table using owner_id.

The final SELECT outputs the user's name, counts for savings and plans, and the total deposit amount from savings.

The result is sorted in descending order of total deposits to highlight high-value customers.

##### Challenges & Resolutions
Avoiding Data Duplication
A direct join between savings_savingsaccount and plans_plan inflated row counts due to one-to-many relationships. I resolved this by aggregating data first in separate CTEs, ensuring accurate counts and sums.


### Question 2: Transaction Frequency Analysis
##### Scenario: The finance team wants to analyze how often customers transact, so we can segment them into groups like frequent and occasional users. This helps in building engagement strategies based on customer behavior.

##### My Approach:
##### 1. Calculate Total Transactions and Active Months:
I started by querying the savings_savingsaccount table to get each customer's total number of transactions and the number of months they have been active. I used TIMESTAMPDIFF between the earliest and latest transaction dates to estimate the customer's active period, then added 1 to include the starting month in the count.

##### 2. Compute Average Transactions Per Month:
Next, I calculated each customer's average monthly transaction count by dividing total transactions by active months. To avoid potential division-by-zero errors, I used NULLIF(active_months, 0).

##### 4. Categorize Customers:
I then classified each customer into a frequency bucket:

High Frequency: 10 or more transactions/month

Medium Frequency: Between 3 and 9 transactions/month

Low Frequency: 2 or fewer transactions/month
This classification helps us understand user engagement levels.

##### 4. Aggregate Results:
Finally, I aggregated the data to find out how many customers fall into each frequency category, along with the average number of monthly transactions for that group. I used the FIELD() function in the ORDER BY clause to ensure the output follows the desired order: High, Medium, then Low.

##### Output Columns:

frequency_category: Segment label based on transaction behavior

customer_count: Number of customers in each segment

avg_transactions_per_month: Segment-level average, rounded to 1 decimal place


### Question 3: Account Inactivity Alert
##### Scenario: The operations team wants to identify active accounts whether savings or investment that have not received any inflow in the past year. This helps surface dormant accounts for potential follow-up or re-engagement strategies.

##### My Approach
I approached this task by breaking it down into logical steps to ensure accuracy and clarity:

1. Identify the Most Recent Inflow per Plan
I focused on finding the most recent transaction (if any) associated with each plan. This allowed me to evaluate account activity on a per-plan basis rather than per customer, ensuring more granular and actionable insights.

2. Merge Plan Details and Status
Using the plan metadata, I filtered out archived and deleted plans to focus only on active ones. This ensured that the output reflected current, relevant data.

3. Calculate Inactivity
For each plan, I calculated the number of days since the last inflow. If there was no transaction history at all, I used the plan's creation date to determine inactivity.

4. Categorize Plan Type
Since the plan type wasn't directly available, I inferred it using keywords in the transaction descriptions. Plans were grouped as either "Savings", "Investment", or "Other", depending on whether the description mentioned these keywords.

##### Challenges & Resolutions
1. Missing Plan Type Field
Problem: The plans_plan table lacked a direct column for plan type.
Solution: I inferred the plan type using the description field in the transaction data, applying keyword-based logic.

2. Plans with No Transactions
I used the created_on date as a fallback to ensure all plans are included, even if no transactions exist.


### Question 4: Customer Lifetime Value (CLV) Estimation
##### Scenario:
Marketing wants to estimate the Customer Lifetime Value (CLV) based on account tenure and transaction volume, using a simplified model.

##### My Approach:

I calculated account tenure in months as the difference between the signup date and today.

I counted only positive, successful transactions to ensure accurate transaction volume.

I estimated CLV by projecting annual profit based on the average profit per transaction (0.1% of average transaction value) scaled by the monthly transaction rate over the customer's tenure.

I used a LEFT JOIN to include all customers, even those with no transactions yet.

The result is ordered by estimated CLV from highest to lowest to prioritize the most valuable customers.


