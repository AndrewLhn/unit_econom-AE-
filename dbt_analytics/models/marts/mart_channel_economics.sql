{{ config(materialized='table') }}

with cac_by_country as (
    select
        country,
        max(cac_30d) as country_cac
    from {{ ref('stg_user_deposits') }}
    group by country
),

base as (
    select
        d.acquisition_channel,
        d.user_id,
        d.total_deposit_30d,
        d.platform_cost_30d,
        c.country_cac
    from {{ ref('stg_user_deposits') }} d
    left join cac_by_country c on d.country = c.country
)

select
    acquisition_channel,
    count(distinct user_id)                                                             as total_users,
    sum(total_deposit_30d)                                                              as total_deposits,
    sum(distinct country_cac)                                                           as total_cac,
    sum(platform_cost_30d)                                                              as total_platform_cost,
    sum(total_deposit_30d) - (sum(distinct country_cac) + sum(platform_cost_30d))      as contribution_margin,

    round((sum(total_deposit_30d) / nullif(count(distinct user_id), 0))::numeric, 2)   as arpu,
    round((sum(distinct country_cac) / nullif(count(distinct user_id), 0))::numeric, 2) as avg_cac,

    round(((sum(total_deposit_30d) - (sum(distinct country_cac) + sum(platform_cost_30d)))
        / nullif(sum(total_deposit_30d), 0) * 100)::numeric, 2)                        as margin_percentage,

    round((sum(total_deposit_30d)
        / nullif((sum(distinct country_cac) + sum(platform_cost_30d)), 0))::numeric, 2) as total_roi

from base
group by 1
order by contribution_margin desc