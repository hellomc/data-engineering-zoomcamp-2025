{{ config(materialized='table') }}

with duration_data as (
    select * from {{ ref('dim_fhv_trips') }}
)

select
    service_type,
    year,
    month,
    pickup_locationid,
    pickup_zone,
    dropoff_locationid,
    dropoff_zone,
    PERCENTILE_CONT(trip_duration, 0.9) OVER (PARTITION BY year, month, pickup_locationid, dropoff_locationid) as duration_p90
from duration_data
where month = 11
    AND pickup_zone in ('Newark Airport', 'SoHo', 'Yorkville East')
order by duration_p90 DESC