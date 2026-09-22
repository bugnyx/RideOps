# RideOps — Driver Retention & Performance Intelligence

> **A business intelligence solution for monitoring driver performance, analyzing retention, and identifying at-risk drivers in a ride-hailing environment.**

[![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20NumPy-blue)](https://www.python.org/)
[![SQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)](https://www.postgresql.org/)
[![Tableau](https://img.shields.io/badge/Visualization-Tableau-orange)](https://www.tableau.com/)
[![Status](https://img.shields.io/badge/Status-Complete-success)]()

---

## 📊 Live Dashboard

### [View the RideOps Dashboard on Tableau Public →](https://public.tableau.com/views/RideOps/ExecutiveOverview)

---

## 📌 Overview

**RideOps** is an end-to-end business intelligence project focused on **driver retention and performance intelligence** for a ride-hailing platform.

The project analyzes longitudinal driver data to identify:

- Driver attrition and retention trends
- Onboarding cohort performance
- City-level retention patterns
- Driver performance deterioration
- Income and business-value trends
- Rating changes
- Driver health categories
- Active drivers requiring retention attention

The solution combines **Python, PostgreSQL, SQL, and Tableau** into an operational analytics workflow.

---

## 🎯 Business Problem

Driver attrition can affect the stability and efficiency of a ride-hailing platform's driver network.

Rather than treating churn as only a prediction problem, RideOps asks:

> **Which drivers are showing signs of declining performance, what patterns are associated with retention and attrition, and which active drivers should an operations team investigate?**

---

## 🧰 Tech Stack

| Technology | Purpose |
|---|---|
| Python | Data preparation and feature engineering |
| Pandas | Data manipulation |
| NumPy | Numerical calculations |
| PostgreSQL | Analytical database |
| SQL | Business and operational analytics |
| Tableau | Interactive dashboards |

---

## 📁 Dataset

The project uses a publicly available **OLA Driver Performance & Attrition dataset** containing:

- **19,104 monthly driver records**
- **2,381 unique drivers**
- Driver demographics
- Joining information
- Monthly income
- Total business value
- Driver grade
- Quarterly rating
- City
- Last working date

The data is longitudinal, allowing driver performance to be analyzed across reporting periods.

> **Note:** This is public OLA data and is not Pathao data. Pathao is used only as a business context for the portfolio project.

---

## 🏗️ Data Architecture

```text
                    Raw OLA Dataset
                           │
                           ▼
                    Python / Pandas
                           │
                 Cleaning & Feature
                    Engineering
                           │
                           ▼
                  ┌─────────────────┐
                  │   PostgreSQL    │
                  └─────────────────┘
                     │           │
                     ▼           ▼
                dim_driver   fact_driver_monthly
                     │           │
                     └─────┬─────┘
                           ▼
                      SQL Analytics
                           │
                           ▼
                        Tableau
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
        Retention      Performance    Action Center
         Analysis        Analysis
```

---

## 🔄 Data Preparation

The Python pipeline performs:

1. Raw dataset loading
2. Column standardization
3. Date parsing
4. Data cleaning
5. Churn flag creation
6. Driver tenure calculation
7. Previous-period metric generation
8. Month-over-month change calculation
9. Driver health-score calculation
10. Dimensional/fact table creation

The final analytical model contains:

- `dim_driver` — 2,381 drivers
- `fact_driver_monthly` — 19,104 monthly observations

---

## 🧮 Driver Health Score

RideOps introduces an interpretable **0–100 Driver Health Score** based on:

| Component | Weight |
|---|---:|
| Income trend | 25% |
| Business-value trend | 25% |
| Current rating | 20% |
| Rating movement | 15% |
| Tenure | 15% |

Drivers are categorized as:

| Score | Category |
|---:|---|
| 70–100 | 🟢 Healthy |
| 50–69.99 | 🔵 Stable |
| 35–49.99 | 🟡 Watch List |
| <35 | 🔴 At Risk |

The score is a heuristic operational-prioritization framework rather than a calibrated probability-of-churn model.

---

## 🔍 SQL Analysis

The SQL layer covers:

### Retention & Attrition
- Monthly active drivers
- Churned drivers
- Attrition trends
- City-level attrition

### Cohort Analysis
- 1-month survival
- 3-month retention
- 6-month retention
- 12-month retention

### Driver Segmentation
- Joining designation
- City
- Health category
- Performance trends

### Performance Analysis
- Income changes
- Business-value changes
- Rating movement
- Grade progression

### Retention Action Center
Identifies currently active drivers classified as **At Risk** for further operational investigation.

---

## 📈 Tableau Dashboards

The Tableau workbook provides an interactive analytical interface for exploring driver retention and performance.

### Executive Overview

High-level monitoring of driver activity, attrition, and performance.

### Retention Analysis

Explores:

- Retention trends
- Cohort survival
- City-level retention
- Joining-designation patterns

### Driver Performance

Examines:

- Income
- Business value
- Rating
- Grade
- Tenure
- Performance changes

### Retention Action Center

Surfaces active drivers classified as **At Risk**, along with the performance indicators that contributed to their classification.

---

## 💡 Business Questions

RideOps is designed to answer questions such as:

- How does driver attrition change over time?
- Which onboarding cohorts show different retention patterns?
- How does retention vary across cities?
- How does joining designation relate to retention?
- Are drivers experiencing declining income?
- Are business-value trends deteriorating?
- How does rating movement relate to churn?
- Which active drivers currently require attention?

---

## 📂 Repository Structure

```text
RideOps/
│
├── ola_driver_scaler.csv
├── ola_driver_cleaned.csv
│
├── dim_driver.csv
├── fact_driver_monthly.csv
│
├── rideOps.ipynb
├── queries.sql
│
└── RideOps.twbx
```

---

## 🚀 Reproducing the Analysis

### 1. Clone the repository

```bash
git clone https://github.com/bugnyx/RideOps.git
cd RideOps
```

### 2. Install Python dependencies

```bash
pip install pandas numpy jupyter
```

### 3. Run the notebook

Open:

```text
rideOps.ipynb
```

The notebook performs the data-cleaning and feature-engineering workflow.

### 4. Load the analytical tables into PostgreSQL

Use:

```text
dim_driver.csv
fact_driver_monthly.csv
```

### 5. Execute the SQL analysis

The analytical queries are available in:

```text
queries.sql
```

### 6. Open the Tableau workbook

Open:

```text
RideOps.twbx
```

or visit the published Tableau dashboard:

**https://public.tableau.com/views/RideOps/ExecutiveOverview**

---

## ⚠️ Limitations

- The dataset is public OLA data rather than Pathao data.
- It does not contain individual ride-level transactions.
- Ride fulfillment, passenger wait time, online hours, and cancellation behavior cannot be directly analyzed.
- The Driver Health Score is a project-defined heuristic.
- Missing `LastWorkingDate` indicates no observed departure within the dataset's observation window, not permanent retention.
- Business Value should not automatically be interpreted as platform revenue.

---

## 🔮 Future Improvements

A production-grade version could incorporate:

- Ride-level transaction data
- Driver online hours
- Completed trips
- Cancellation rate
- Incentive participation
- Driver acquisition channels
- Driver support interactions
- Supply-demand metrics
- Retention campaign tracking
- Automated data refresh
- Calibrated churn prediction
- Tableau alerts for newly emerging at-risk drivers

---

## 👤 Author

**Moin Ahammed**

Computer Science | Data Analytics | Machine Learning

- GitHub: https://github.com/bugnyx
- Project: https://github.com/bugnyx/RideOps
- Tableau: https://public.tableau.com/views/RideOps/ExecutiveOverview

---

## 📄 License

This project is intended for educational and portfolio purposes. The underlying dataset is publicly sourced and remains subject to its original terms of use.