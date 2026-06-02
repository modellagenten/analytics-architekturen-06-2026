{% macro macro_hub(tabellenname, src_table, primary_key) %}

    {{ config(unique_key='hk_' + tabellenname) }}

    with src as (
        select
            {{ get_hash_key([primary_key]) }}  as hk_{{tabellenname}},
            {{primary_key}},
            load_ts,
            '{{src_table}}' as record_source
        from {{ ref(src_table) }}
        where {{primary_key}} is not null
    )

    select * from src
    {% if is_incremental() %}
    where hk_{{tabellenname}} not in (select hk_{{tabellenname}} from {{ this }})
    {% endif %}
{% endmacro %}

-- {{macro_hub('vermittler', 'stg_vertraege', 'vermittler_code')}}