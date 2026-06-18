with cohort_deposits as (
    select sum(total_deposits) as amount from {{ ref('mart_cohort_economics') }}
),

channel_deposits as (
    select sum(total_deposits) as amount from {{ ref('mart_channel_economics') }}
),

geo_deposits as (
    select sum(total_deposits) as amount from {{ ref('mart_geo_economics') }}
)

select *
from (
    select 
        c.amount as cohort_amt, 
        ch.amount as channel_amt, 
        g.amount as geo_amt
    from cohort_deposits c
    cross join channel_deposits ch
    cross join geo_deposits g
) as reconciliation 
where round(cohort_amt::numeric) != round(channel_amt::numeric) 
   or round(cohort_amt::numeric) != round(geo_amt::numeric)