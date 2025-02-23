{{
    config(
        materialized='view'
    )
}}

with tripdata as 
(
  select *,
    row_number() over(partition by Dispatching_base_num, Pickup_datetime) as rn
  from {{ source('staging','fhv_tripdata') }}
  where Dispatching_base_num is not null 
)
select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['Dispatching_base_num', 'Pickup_datetime']) }} as tripid,
    {{ dbt.safe_cast("Dispatching_base_num", api.Column.translate_type("string")) }} as dispatching_base_num,
    {{ dbt.safe_cast("PUlocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("DOlocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,

    -- timestamps
    cast(Pickup_datetime as timestamp) as pickup_datetime,
    cast(DropOff_datetime as timestamp) as dropoff_datetime,

    -- trip info
    SR_Flag
from tripdata
where rn = 1 