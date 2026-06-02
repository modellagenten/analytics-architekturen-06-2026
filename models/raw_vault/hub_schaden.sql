{{ config(unique_key='hk_schaden') }}

with src as (
    select
        {{ get_hash_key(['schaden_id']) }}  as hk_schaden,
        schaden_id,
        load_ts,
        'stg_schaden_events' as record_source
    from {{ ref('stg_schaden_events') }}
    where schaden_id is not null
)

select * from src
{% if is_incremental() %}
where hk_schaden not in (select hk_schaden from {{ this }})
{% endif %}