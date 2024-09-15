{% macro extract_number(column, type='numeric(12, 2)', alias=None, quote=False) -%}
    {%- if not column or column is not string -%}
        {%- set error_message -%}
            The macro `extract_number` requires a mandatory `string` argument: `column`
        {%- endset -%}
        {{ exceptions.raise_compiler_error(error_message) }}
    {%- endif %}
    {%- set column = adapter.quote(column) if quote else column -%}
    CASE
        WHEN {{ column }} IS NULL
            THEN NULL
        WHEN POSITION('$' IN {{ column }}) > 0
			THEN SUBSTRING({{ column }} FROM 2)
		WHEN POSITION('USD' IN {{ column }}) > 0
			THEN TRIM(BOTH FROM SPLIT_PART({{ column }}, 'USD', 1))
		WHEN POSITION('k' IN {{ column }}) > 0
			THEN SPLIT_PART({{ column }}, 'k', 1) || '000'
		ELSE {{ column }}
	END::{{ type }} AS {% if alias and alias is string -%} {{ alias }} {%- else -%} {{ column }} {%- endif %}
{%- endmacro %}
