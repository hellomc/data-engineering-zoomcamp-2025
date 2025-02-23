{{ config(materialized='table') }}

with quarterly_revenue AS (
    SELECT
        service_type,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(quarter FROM pickup_datetime) AS quarter,
        SUM(total_amount) AS revenue
    FROM {{ ref('fact_trips') }}
    WHERE EXTRACT(YEAR FROM pickup_datetime) IN (2019, 2020)
    GROUP BY service_type,year,quarter
),

quarterly_compare AS (
    SELECT
        year, 
        quarter,
        service_type,
        revenue,
        LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year) AS prev_qy_revenue,
        ROUND (100 * ((revenue - LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year))
            / NULLIF(LAG(revenue) OVER (PARTITION BY service_type, quarter ORDER BY year), 0)), 2) AS qy_growth_percent
    FROM quarterly_revenue
)

SELECT * FROM quarterly_compare