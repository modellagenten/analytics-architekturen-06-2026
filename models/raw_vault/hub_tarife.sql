-- models/raw_vault/hub_tarife.sql
{{ config(unique_key='hk_tarife') }}

with src as (
    select
        {{ get_hash_key(['tarif_code', 'sparte', 'monat_nr']) }}  as hk_tarife,
        concat(tarif_code, sparte, monat_nr) bk_tarife,
        load_ts,
        'stg_tarife' as record_source
    from {{ ref('stg_tarife') }}
    where tarif_code is not null and sparte is not null
)

select * from src
{% if is_incremental() %}
where hk_tarife not in (select hk_tarife from {{ this }})
{% endif %}