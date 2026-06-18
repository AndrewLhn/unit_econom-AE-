{{ config(materialized='table') }}

with geo_aggregation as (
    select
        country,
        count(distinct user_id) as total_users,
        sum(total_deposit_30d) as total_deposits,
        sum(cac_30d) as total_cac,                          -- СУМУЄМО, бо це витрата на кожного користувача
        sum(platform_cost_30d) as total_platform_cost        -- сумуємо
    from {{ ref('stg_user_deposits') }}
    group by 1
)

select
    country,
    total_users,
    total_deposits,
    total_cac,
    total_platform_cost,
    
    -- Чистий Contribution Margin (CM)
    (total_deposits - total_cac - total_platform_cost) as contribution_margin,

    -- Точний ARPU без заокруглень при розрахунках
    round((total_deposits / nullif(total_users, 0))::numeric, 2) as arpu,
    
    -- Середній САС на юзера
    round((total_cac / nullif(total_users, 0))::numeric, 2) as avg_cac,

    -- Відсоток маржинальності (Margin %)
    round(
        (((total_deposits - total_cac - total_platform_cost) / nullif(total_deposits, 0)) * 100)::numeric, 
        2
    ) as margin_percentage,

    -- Справжній ROI (Маржа / Кости * 100) для бізнес-логіки
    round(
        (((total_deposits - total_cac - total_platform_cost) / nullif(total_cac, 0)) * 100)::numeric, 
        2
    ) as total_roi

from geo_aggregation
order by contribution_margin desc