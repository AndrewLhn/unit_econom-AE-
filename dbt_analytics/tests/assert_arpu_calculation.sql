with data as (
    select 
        acquisition_channel,
        total_users,
        total_deposits,
        arpu,
        round((total_deposits / nullif(total_users, 0))::numeric, 2) as expected_arpu
    from {{ ref('mart_channel_economics') }}
)

select *
from data
where abs(arpu - expected_arpu) > 0.01