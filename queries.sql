--Q1: Monthly Active Drivers, Churned Drivers & Attrition Rate Trend
SELECT
	reporting_date,
	count(DISTINCT driver_id) as active_drivers,
	count(DISTINCT CASE WHEN last_working_date is not null then driver_id end) as churned_drivers,
	round(
		100.0 * COUNT(DISTINCT CASE WHEN last_working_date IS NOT NULL THEN driver_id END) / 
        NULLIF(COUNT(DISTINCT driver_id), 0), 2
	) AS monthly_attrition_rate_pct
FROM fact_driver_monthly
GROUP BY reporting_date
ORDER BY reporting_date;

--Q2: Churn & Business Value Impact by City
SELECT
	d.city,
	COUNT(DISTINCT d.driver_id) AS total_historical_drivers,
	SUM(f.is_churned) AS total_churned_drivers,
	ROUND(100.0 * SUM(f.is_churned) / COUNT(DISTINCT d.driver_id), 2) AS cumulative_attrition_rate_pct,
	SUM(f.total_business_value) AS total_revenue_generated
FROM
	dim_driver d
	JOIN (
		SELECT
			driver_id,
			MAX(is_churned) AS is_churned,
			SUM(total_business_value) AS total_business_value
		FROM
			fact_driver_monthly
		GROUP BY
			driver_id
	) f ON d.driver_id = f.driver_id
GROUP BY
	d.city
ORDER BY
	cumulative_attrition_rate_pct DESC;

-- Churn Rate by Month
SELECT 
    f.reporting_date,
    d.city,
    COUNT(DISTINCT f.driver_id) AS active_drivers,
    SUM(f.is_churned) AS churned_in_month,
    ROUND(100.0 * SUM(f.is_churned) / COUNT(DISTINCT f.driver_id), 2) AS monthly_churn_rate_pct,
    SUM(f.total_business_value) AS monthly_revenue
FROM fact_driver_monthly f
JOIN dim_driver d ON f.driver_id = d.driver_id
GROUP BY f.reporting_date, d.city
ORDER BY f.reporting_date DESC, monthly_churn_rate_pct DESC;


--Q4: 3: Driver Onboarding Cohort Matrix (1, 3, 6, 12 Month Survival Rates)
WITH cohort_data AS (
    SELECT 
        d.driver_id,
        DATE_TRUNC('month', d.joining_date)::DATE AS cohort_month,
        MAX(f.tenure_months) AS max_tenure,
        MAX(f.is_churned) AS overall_churned
    FROM dim_driver d
    JOIN fact_driver_monthly f ON d.driver_id = f.driver_id
    GROUP BY d.driver_id, DATE_TRUNC('month', d.joining_date)
)
SELECT 
    cohort_month,
    COUNT(driver_id) AS total_cohort_size,
    COUNT(CASE WHEN max_tenure >= 1 THEN 1 END) AS retained_m1,
    COUNT(CASE WHEN max_tenure >= 3 THEN 1 END) AS retained_m3,
    COUNT(CASE WHEN max_tenure >= 6 THEN 1 END) AS retained_m6,
    COUNT(CASE WHEN max_tenure >= 12 THEN 1 END) AS retained_m12,
    ROUND(100.0 * COUNT(CASE WHEN max_tenure >= 3 THEN 1 END) / COUNT(driver_id), 2) AS m3_retention_pct,
    ROUND(100.0 * COUNT(CASE WHEN max_tenure >= 6 THEN 1 END) / COUNT(driver_id), 2) AS m6_retention_pct
FROM cohort_data
GROUP BY cohort_month
ORDER BY cohort_month;

--Q4: Retention Rate by Joining Designation
SELECT 
    d.joining_designation,
    COUNT(DISTINCT d.driver_id) AS total_drivers,
    SUM(f.is_churned) AS churned_count,
    ROUND(100.0 * (1.0 - (SUM(f.is_churned)::NUMERIC / COUNT(DISTINCT d.driver_id))), 2) AS overall_retention_rate_pct,
    ROUND(AVG(f.tenure_months), 1) AS avg_tenure_months
FROM dim_driver d
JOIN (
    SELECT driver_id, MAX(is_churned) AS is_churned, MAX(tenure_months) AS tenure_months
    FROM fact_driver_monthly
    GROUP BY driver_id
) f ON d.driver_id = f.driver_id
GROUP BY d.joining_designation
ORDER BY d.joining_designation;

--Q5: Driver Health Category Distribution & Revenue Breakdown
SELECT 
    health_category,
    COUNT(DISTINCT driver_id) AS total_monthly_records,
    ROUND(AVG(income_change_pct), 2) AS avg_income_change_pct,
    ROUND(AVG(bv_change_pct), 2) AS avg_bv_change_pct,
    ROUND(AVG(total_business_value), 2) AS avg_monthly_business_value
FROM fact_driver_monthly
GROUP BY health_category
ORDER BY avg_monthly_business_value DESC;

--Q6: Retention Action Center (High-Value Drivers "At Risk")
WITH latest_month AS (
    SELECT MAX(reporting_date) AS max_date FROM fact_driver_monthly
)
SELECT 
    f.reporting_date,
    f.driver_id,
    d.city,
    f.income,
    f.income_change_pct,
    f.bv_change_pct,
    f.quarterly_rating,
    f.health_score,
    f.health_category
FROM fact_driver_monthly f
JOIN dim_driver d ON f.driver_id = d.driver_id
JOIN latest_month lm ON f.reporting_date = lm.max_date
WHERE f.health_category = 'At Risk' 
  AND f.last_working_date IS NULL
ORDER BY f.income DESC;

--Q7: Impact of Quarterly Rating Drop on Churn Rate
SELECT
	CASE
		WHEN rating_change < 0 THEN 'Rating Dropped'
		WHEN rating_change = 0 THEN 'Rating Unchanged'
		ELSE 'Rating Increased'
	END AS rating_trend,
	COUNT(DISTINCT driver_id) AS record_count,
	SUM(is_churned) AS churn_count,
	ROUND(100.0 * SUM(is_churned) / COUNT(*), 2) AS churn_rate_pct
FROM
	fact_driver_monthly
GROUP BY
	CASE
		WHEN rating_change < 0 THEN 'Rating Dropped'
		WHEN rating_change = 0 THEN 'Rating Unchanged'
		ELSE 'Rating Increased'
	END
ORDER BY
	churn_rate_pct DESC;

--Q8: Promotion & Grade Change vs. Driver Retention
WITH driver_promotions AS (
    SELECT 
        driver_id,
        MAX(grade) - MIN(grade) AS grade_delta,
        MAX(is_churned) AS final_churn_status
    FROM fact_driver_monthly
    GROUP BY driver_id
)
SELECT 
    CASE WHEN grade_delta > 0 THEN 'Promoted' ELSE 'No Promotion' END AS promotion_status,
    COUNT(driver_id) AS total_drivers,
    SUM(final_churn_status) AS churned_drivers,
    ROUND(100.0 * SUM(final_churn_status) / COUNT(driver_id), 2) AS churn_rate_pct
FROM driver_promotions
GROUP BY CASE WHEN grade_delta > 0 THEN 'Promoted' ELSE 'No Promotion' END;

