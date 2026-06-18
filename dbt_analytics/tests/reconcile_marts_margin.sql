with cohort_total as (
     select round(sum(contribution_margin)::numeric, 2) as total_margin
     from {{ ref('mart_cohort_economics') }}
),
channel_total as (
     select round(sum(contribution_margin)::numeric, 2) as total_margin
     from {{ ref('mart_channel_economics') }}
),
geo_total as (
     select round(sum(contribution_margin)::numeric, 2) as total_margin
     from {{ ref('mart_geo_economics') }}
)
select c.total_margin as cohort_margin,
     ch.total_margin as channel_margin,
     g.total_margin as geo_margin
from cohort_total c
cross join channel_total ch
cross join geo_total g
where c.total_margin != ch.total_margin
     or c.total_margin != g.total_margin
