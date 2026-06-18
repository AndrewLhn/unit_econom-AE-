with check_channels as (
    select 
        acquisition_channel as entity,
        arpu,
        round((total_deposits / nullif(total_users, 0))::numeric, 2) as expected_arpu
    from {{ ref('mart_channel_economics') }}
),

check_geo as (
    select 
        country as entity,
        arpu,
        round((total_deposits / nullif(total_users, 0))::numeric, 2) as expected_arpu
    from {{ ref('mart_geo_economics') }}
),

combined_checks as (
    select * from check_channels
    union all
    select * from check_geo
)

select *
from combined_checks
where abs(arpu - expected_arpu) > 0.01