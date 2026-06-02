{{ config(unique_key='hk_vermittler') }}

with src as (
    select
        {{ get_hash_key(['vermittler_code']) }}  as hk_vermittler,
        vermittler_code,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
    where vermittler_code is not null
)

select * from src
{% if is_incremental() %}
where hk_vermittler not in (select hk_vermittler from {{ this }})
{% endif %}