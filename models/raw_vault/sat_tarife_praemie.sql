-- models/raw_vault/sat_<entity>_<thema>.sql
{{ config(unique_key=['hk_tarife', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['tarif_code', 'sparte', 'monat_nr']) }} as hk_tarife,
        {{ get_hash_diff([
            'monat_nr',
            'praemie_monat',
            'quartal',
            'gueltig_ab',
            'geaendert_am'
        ]) }} as hd_tarife_praemie,
        monat_nr,
        praemie_monat,
        quartal,
        gueltig_ab,
        geaendert_am,
        load_ts,
        'stg_tarife' as record_source
    from {{ ref('stg_tarife') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where concat(hk_tarife, hd_tarife_praemie) not in (
    select concat(hk_tarife, hd_tarife_praemie) from {{ this }}
)
{% endif %}