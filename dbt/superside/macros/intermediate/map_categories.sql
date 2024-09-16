{% macro map_categories(column, categories, max_distance=2, alias=None, quote=False) -%}
    {%- if not column or column is not string -%}
        {%- set error_message -%}
            The macro `map_categories` requires a mandatory `string` argument: `column`
        {%- endset -%}
        {{ exceptions.raise_compiler_error(error_message) }}
    {%- endif %}
    {%- set column = adapter.quote(column) if quote else column -%}
    CASE
        WHEN {{ column }} IS NULL
            THEN NULL
        {%- for category in categories %}
        WHEN LEVENSHTEIN('{{ category }}', {{ column }}) < {{ max_distance }}
            THEN '{{ category }}'
        {%- endfor %}
        ELSE {{ column }}
    END AS {% if alias and alias is string -%} {{ alias }} {%- else -%} {{ column }} {%- endif %}
{%- endmacro %}
