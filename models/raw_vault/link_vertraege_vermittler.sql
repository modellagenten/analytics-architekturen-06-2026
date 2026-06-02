{{ config(unique_key='hk_l_vertraege_vermittler') }}

with src as (
    select
        {{ get_hash_key(['vertrag_id', 'vermittler_code']) }} as hk_l_vertraege_vermittler,
        {{ get_hash_key(['vertrag_id']) }}            as hk_vertraege,
        {{ get_hash_key(['vermittler_code']) }}            as hk_vermittler,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
    where vertrag_id is not null
      and vermittler_code is not null
)

select * from src
{% if is_incremental() %}
where hk_l_vertraege_vermittler not in (select hk_l_vertraege_vermittler from {{ this }})
{% endif %}