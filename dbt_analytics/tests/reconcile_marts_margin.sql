WITH cohort_total AS (
    SELECT ROUND(SUM(contribution_margin)::numeric, 2) AS total_margin 
    FROM {{ ref('mart_cohort_economics') }}
),

geo_total AS (
    SELECT ROUND(SUM(contribution_margin)::numeric, 2) AS total_margin 
    FROM {{ ref('mart_geo_economics') }}
)

SELECT 
    c.total_margin AS cohort_margin, 
    g.total_margin AS geo_margin
FROM cohort_total c
CROSS JOIN geo_total g
WHERE c.total_margin != g.total_margin