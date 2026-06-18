 [ RAW DATA ]       ──>  PostgreSQL (raw_source_user_deposits)
                                       │
                                       ▼
 [ dbt STAGING ]    ──>  stg_user_deposits (View)
                                       │  ├── test: unique(user_id)
                                       │  └── test: not_null
                                       ▼
 [ dbt MARTS ]      ──>  Transformation & Data Quality (18 Tests: PASS)
                                       │
                ┌──────────────────────┼──────────────────────┐
                ▼                      ▼                      ▼
     mart_cohort_economics   mart_channel_economics   mart_geo_economics
        (Cohort & ROI)        (9 Whitelisted Sources)    (Geo Sales)
                │                      │                      │
                └──────────────────────┼──────────────────────┘
                                       │
                                       ▼
 [ BI LAYER ]       ──>  Metabase Dashboards

##Project Summary:

##Ingest: Raw user deposit logs and CSV files are loaded into raw_source_user_deposits.

##Stage: The stg_user_deposits view deduplicates records by user_id and cleans string fields.

##Model: Modular CTEs transform data into 3 core tables: mart_cohort_economics, mart_channel_economics, and mart_geo_economics.

##Test: A robust suite of 18 automated tests ensures data quality (validates not_null, unique, whitelists 9 ad channels, and enforces cross-metric logic like ROI > 1 $\rightarrow$ Margin > 0).

##Visualize: Clean tables are hooked directly to Metabase to power cohort, channel efficiency, and geo-performance dashboards.

docker compose up -d

./venv/bin/dbt build --project-dir dbt_analytics --profiles-dir dbt_analytics


«В архитектуру dbt заложен принцип Data Integrity. Написан custom test reconcile_marts_margin, который блокирует деплой моделей в прод (CI/CD), якщо сумма Contribution Margin в разрезе когорт расходится с разрезом по Geo или Channels хотя бы на 1 цент». Для мидла/сеньора это железобетонный аргумент.