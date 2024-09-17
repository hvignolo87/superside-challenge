WITH raw_data AS (
    SELECT
        project_id::uuid
        , engagement_id::uuid
        , customer_id
        , LOWER(customer_name) AS customer_name
        , engagement_date
        , revenue
        , revenue_usd
        , INITCAP("service") AS "service"
        , sub_service
        , engagement_type
        , employee_count
        , comments
        , project_ref::uuid
        , engagement_reference
        , client_revenue
        , service_type
        , detailed_sub_service
    FROM {{ source('clients', 'engagement_metrics') }}
)

, deduplicated AS (
    SELECT
        *
        , ROW_NUMBER() OVER (
            PARTITION BY project_id, engagement_id
        ) AS row_index
    FROM raw_data
)

SELECT
    project_id
    , engagement_id
    , customer_id
    , customer_name
    , engagement_date
    , revenue
    , revenue_usd
    , "service"
    , sub_service
    , engagement_type
    , employee_count
    , comments
    , project_ref
    , engagement_reference
    , client_revenue
    , service_type
    , detailed_sub_service
FROM deduplicated
WHERE row_index = 1
