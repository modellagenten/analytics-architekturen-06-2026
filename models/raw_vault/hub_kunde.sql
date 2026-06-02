-- models/raw_vault/hub_<entity>.sql
{{ config(unique_key='hk_kunde') }}

with src as (
    select
        {{ get_hash_key(['kunde_id']) }}  as hk_kunde,
        kunde_id,
        load_ts,
        'stg_kunden' as record_source
    from {{ ref('stg_kunden') }}
    where kunde_id is not null
)

select * from src
{% if is_incremental() %}
where hk_kunde not in (select hk_kunde from {{ this }})
{% endif %}