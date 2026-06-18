with source as (
    select * from {{ source('raw', 'user_deposits') }}  
)

select
    user_id,
    cast(first_deposit_date as date) as first_deposit_date,
    acquisition_channel,
    country,
    total_deposit_30d, 
    customer_acquisition_cost_30d as cac_30d, 
    platform_cost_30d
from source