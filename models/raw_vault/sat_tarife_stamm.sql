-- models/raw_vault/sat_tarife_stamm.sql
{{ config(unique_key=['hk_tarife', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['tarif_code', 'sparte', 'monat_nr']) }} as hk_tarife,
        {{ get_hash_diff([
            'tarif_code',
            'sparte',
            'monat_nr'
        ]) }} as hd_tarife_stamm,
        tarif_code,
        sparte,
        monat_nr,
        load_ts,
        'stg_tarife' as record_source
    from {{ ref('stg_tarife') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where concat(hk_tarife, hd_tarife_stamm) not in (
    select concat(hk_tarife, hd_tarife_stamm) from {{ this }}
)
{% endif %}