{{ config(materialized='table') }}

with filtered_trips AS (
    SELECT
        service_type,
        DATE_TRUNC('month', pickup_datetime) AS month_start,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(MONTH FROM pickup_datetime) AS month,
        fare_amount
    FROM {{ ref('fact_trips') }}
    WHERE
        fare_amount > 0
        AND trip_distance > 0
        AND payment_type_description IN ('Cash', 'Credit card')
)

SELECT
    service_type,
    month_start,
    year,
    month,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY fare_amount) 
        OVER (PARTITION BY service_type, year, month) AS fare_p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY fare_amount) 
        OVER (PARTITION BY service_type, year, month) AS fare_p95,
    PERCENTILE_CONT(0.97) WITHIN GROUP (ORDER BY fare_amount) 
        OVER (PARTITION BY service_type, year, month) AS fare_p97
FROM filtered_trips
ORDER BY service_type, year, month