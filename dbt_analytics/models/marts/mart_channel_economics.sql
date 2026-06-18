{{ config(materialized='table') }}

with channel_aggregation as (
    select
        acquisition_channel,
        count(distinct user_id) as total_users,
        sum(total_deposit_30d) as total_deposits,  
        sum(cac_30d) as total_cac,                 
        sum(platform_cost_30d) as total_platform_cost 
    from {{ ref('stg_user_deposits') }}
    group by 1
)

select
    acquisition_channel,
    total_users,
    total_deposits,
    total_cac,
    total_platform_cost,
    (total_deposits - total_cac - total_platform_cost) as contribution_margin,
    round((total_deposits / nullif(total_users, 0))::numeric, 2) as arpu,
    round((total_cac / nullif(total_users, 0))::numeric, 2) as avg_cac,
    round(((total_deposits - total_cac - total_platform_cost) / nullif(total_deposits, 0) * 100)::numeric, 2) as margin_percentage,
    round(((total_deposits - total_cac - total_platform_cost) / nullif(total_cac, 0) * 100)::numeric, 2) as total_roi
from channel_aggregation 
order by contribution_margin desc