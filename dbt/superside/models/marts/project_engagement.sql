SELECT
    -- IDs
    metrics.project_id
    , metrics.engagement_id
    , metrics.customer_id
    , metrics.project_ref
    , metrics.engagement_reference
    , dim_project.customer_id AS dim_customer_id
    , dim_project.project_service_id
    , dim_project.product_id
    , dim_project.team_id
    , dim_project.cpm_id
    , dim_project.dim_cpm_id
    , dim_project.id AS dim_project_id

    -- Dimensions / Filters
    , metrics.customer_name
    , metrics."service"
    , metrics.sub_service
    , dim_project."service" AS dim_service
    , dim_project.sub_service AS dim_sub_service
    , metrics.service_type
    , metrics.detailed_sub_service
    , metrics.engagement_type
    , dim_project.folder
    , dim_project.status
    , dim_project."name"
    , dim_project.staffing_version
    , dim_project.product
    , dim_project.team
    , dim_project.team_type
    , dim_project.quality
    , dim_project.delivery
    , dim_project.source_app

    -- Names / Others
    , metrics."comments"
    , dim_project."description"
    , dim_project.internal_description
    , dim_project.cpm

    -- Booleans
    , dim_project.is_critical_delivery
    , dim_project.is_critical_delivery_success
    , dim_project.is_submitted_from_internal
    , dim_project.is_created_with_deliverables
    , dim_project.is_project_ai_enabled

    -- Metrics
    , metrics.employee_count
    , metrics.client_revenue
    , metrics.revenue
    , metrics.revenue_usd
    , dim_project.rate
    , dim_project.discount
    , dim_project.min_estimate
    , dim_project.max_estimate
    , dim_project.sp_estimate
    , dim_project.pm_estimate
    , dim_project.ad_estimate

    -- Dates
    , metrics.engagement_date
    , dim_project."timezone"
    , dim_project.date_project_created
    , dim_project.date_project_submitted
    , dim_project.date_project_deadline
    , dim_project.date_project_grabbed
    , dim_project.date_project_started
    , dim_project.date_project_ended
    , dim_project.date_project_updated
FROM {{ ref('fct_engagement_metrics') }} AS metrics
LEFT JOIN {{ ref('dim_project') }} AS dim_project
    ON metrics.project_id = dim_project.project_id
