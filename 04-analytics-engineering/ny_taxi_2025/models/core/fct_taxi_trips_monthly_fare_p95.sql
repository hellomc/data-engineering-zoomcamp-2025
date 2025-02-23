{{ config(materialized='table') }}

with filtered_trips AS (
    SELECT
        service_type,
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
    year,
    month,
    PERCENTILE_CONT(fare_amount, 0.90 RESPECT NULLS)
        OVER (PARTITION BY service_type, year, month) AS fare_p90,
    PERCENTILE_CONT(fare_amount, 0.95 RESPECT NULLS) 
        OVER (PARTITION BY service_type, year, month) AS fare_p95,
    PERCENTILE_CONT(fare_amount, 0.97 RESPECT NULLS)
        OVER (PARTITION BY service_type, year, month) AS fare_p97
FROM filtered_trips
ORDER BY service_type, year, month