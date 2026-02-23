# Customer Revenue Concentration & Retention Risk Analysis
- Project Overview

This project performs an end-to-end SQL analysis of customer revenue concentration and retention risk for a subscription-based SaaS business.

The key objectives were to:

Identify revenue dependency on high-value customers

Analyze cohort-based retention trends

Quantify revenue exposure from customer churn

Support data-driven retention strategy decisions

A normalized relational database was designed to simulate real-world SaaS data, integrating:

Customer profiles

Subscription history

Payment transactions

User engagement metrics

Business Objectives

Measure revenue concentration and cumulative contribution

Evaluate retention trends across monthly customer cohorts

Quantify revenue at risk from churned customers

Compare revenue distribution across customer segments

Tools & Technologies

MySQL

Advanced SQL: Multi-table Joins, CTEs, Window Functions

Cohort Analysis

Revenue Segmentation

Dataset Structure
Table Name	Description
customers	Demographics and signup data
subscriptions	Plan details and churn indicators
payments	Transaction-level revenue data
customer_activity	Engagement and usage metrics
Key Analyses Performed

Revenue concentration and cumulative revenue distribution

Monthly cohort-based retention analysis

Revenue-at-risk calculation for churned customers

Segment-level revenue contribution analysis

Engagement-based churn risk evaluation

Key Business Insights

A small percentage of customers contribute a disproportionately large share of revenue → high concentration risk

Newer customer cohorts show declining retention compared to earlier cohorts

Churned customers represent a measurable portion of historical revenue → financial exposure beyond churn counts

Enterprise and Mid-Market segments generate the majority of revenue

Business Impact

This analysis provides a structured framework for:

Prioritizing high-value customer retention

Implementing early churn detection based on engagement patterns

Reducing long-term revenue dependency risk

Supporting strategic revenue diversification decisions

Visualizations


Monthly cohort retention rate per signup cohort


Total revenue contribution per customer

Skills Demonstrated

End-to-end SQL analysis and database design

Advanced SQL: CTEs, Window Functions, Joins, Aggregations

Cohort and retention analysis

Revenue segmentation and financial exposure assessment

Translating SQL insights into actionable business strategy

Author

Neha Raut
