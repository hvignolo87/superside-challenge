{{
    config(
        pre_hook="CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
    )
}}

{%- set dates_mappings = {
    '^\d{2}/\d{2}/\d{4}$': 'MM/DD/YYYY',
    '^\d{4}/\d{2}/\d{2}$': 'YYYY/MM/DD',
    '^\d{4}-\d{2}-\d{2}$': 'YYYY-MM-DD',
    '^\d{2}-\d{2}-\d{4}$': 'DD-MM-YYYY',
    '^\d{2}\.\d{2}\.\d{4}$': 'DD.MM.YYYY',
    '^\d{4}\.\d{2}\.\d{2}$': 'YYYY.MM.DD',
    '^\d{2}\.\d{2}\.\d{4}$': 'MM.DD.YYYY',
    '^\d{2}/\d{2}/\d{2}$': 'MM/DD/YY'
 } -%}

SELECT
    project_id
    , engagement_id
    , customer_id::int4
    , "comments"
    , project_ref
    , engagement_reference
    , CASE
        WHEN customer_name IS NULL
            THEN NULL
        WHEN POSITION('_' IN customer_name) = 0
            THEN 'customer_' || SUBSTRING(SPLIT_PART(customer_name, 'customer', 2) FROM '[0-9]+')
        WHEN POSITION('_' IN customer_name) > 0
            THEN 'customer_' || SUBSTRING(SPLIT_PART(customer_name, '_', 2) FROM '[0-9]+')
    END AS customer_name
    {% for regex, date_format in dates_mappings.items() -%}
        {% if loop.first -%}
            , CASE
        {%- endif %}
            WHEN engagement_date ~ '{{ regex }}'
                THEN TO_DATE(engagement_date, '{{ date_format }}')
        {%- if loop.last %}
            END::date AS engagement_date
        {%- endif -%}
    {%- endfor %}
    , CASE
        WHEN employee_count IS NULL
            THEN NULL
        WHEN employee_count ~ '^\d+$'
            THEN employee_count::int4
        WHEN employee_count = 'fifty'
            THEN 50
        WHEN employee_count = 'hundred'
            THEN 100
    END::int4 AS employee_count
    , {{ extract_number('revenue') }}
    , {{ extract_number('revenue_usd') }}
    , {{ extract_number('client_revenue') }}
    , {{
        map_categories(
            'service',
            var('service_categories'),
            quote=True
        )
    }}
    , {{
        map_categories(
            'sub_service',
            var('sub_service_categories')
        )
    }}
    , {{
        map_categories(
            'engagement_type',
            var('engagement_type_categories')
        )
    }}
    , {{
        map_categories(
            'service_type',
            var('service_categories')
        )
    }}
    , {{
        map_categories(
            'detailed_sub_service',
            var('sub_service_categories')
        )
    }}
FROM {{ ref('stg_clients__engagement_metrics') }}
