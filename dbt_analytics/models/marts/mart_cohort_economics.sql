{{ config(
    materialized='table'
) }}

WITH cohort_aggregation AS (
    SELECT
        DATE_TRUNC('month', first_deposit_date)::DATE AS cohort_month,
        COUNT(DISTINCT user_id) AS users, 
        SUM(total_deposit_30d) AS total_deposits, 
        SUM(cac_30d) AS total_cac, 
        SUM(platform_cost_30d) AS total_platform_cost
    FROM {{ ref('stg_user_deposits') }}
    GROUP BY 1
)

SELECT
    cohort_month,
    users,
    total_deposits,
    total_cac, 
    -- Расчет Contribution Margin (CM)
    (total_deposits - total_cac - total_platform_cost) AS contribution_margin,
    -- Процент маржинальности
    ROUND(
        (((total_deposits - total_cac - total_platform_cost) / NULLIF(total_deposits, 0)) * 100)::numeric, 
        2
    ) AS margin_percentage,
    -- Расчет ROI для совместимости с тестом dbt (Маржа / CAC * 100)
    ROUND(
        (((total_deposits - total_cac - total_platform_cost) / NULLIF(total_cac, 0)) * 100)::numeric, 
        2
    ) AS roi,
    -- CM на одного пользователя
    ROUND(
        ((total_deposits - total_cac - total_platform_cost) / NULLIF(users, 0))::numeric, 
        2
    ) AS cm_per_user
FROM cohort_aggregation
ORDER BY cohort_month ASC