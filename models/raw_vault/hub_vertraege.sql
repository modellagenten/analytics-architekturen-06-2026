{{ config(unique_key='hk_vertraege') }}

with src as (
    select
        {{ get_hash_key(['vertrag_id']) }}  as hk_vertraege,
        vertrag_id,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
    where vertrag_id is not null
)

select * from src
{% if is_incremental() %}
where hk_vertraege not in (select hk_vertraege from {{ this }})
{% endif %}