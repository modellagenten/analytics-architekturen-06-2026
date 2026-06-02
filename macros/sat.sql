{% macro macro_sat(tabellenname, sat_name, primary_key, attributes) %}

    {{ config(unique_key=['hk_' + tabellenname, 'load_ts']) }}

    with src as (
        select
            {{ get_hash_key([primary_key]) }} as hk_{{tabellenname}},
            {{ get_hash_diff(attributes) }} as hd_{{tabellenname}}_{{sat_name}},
            {% for attr in attributes -%}
                {{attr}},
            {%- endfor %}
            load_ts,
            'stg_{{tabellenname}}' as record_source
        from {{ ref('stg_' + tabellenname) }}
    )

    select * from src
    {% if is_incremental() %}
    -- nur neue inhaltliche Stände einfügen
    where CONCAT(hk_{{tabellenname}}, hd_{{tabellenname}}_{{sat_name}}) not in (
        select CONCAT(hk_{{tabellenname}}, hd_{{tabellenname}}_{{sat_name}}) from {{ this }}
    )
    {% endif %}
{% endmacro %}

-- {{macro_sat('vertraege', 'gueltigkeit', 'vertrag_id', ['beginn_datum', 'ende_datum', 'status_code', 'storno_flag'])}}