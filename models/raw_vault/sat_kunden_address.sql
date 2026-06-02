-- models/raw_vault/sat_<entity>_<thema>.sql
{{ config(unique_key=['hk_kunde', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['kunde_id']) }} as hk_kunde,
        {{ get_hash_diff([
            'strasse_hsnr',
            'plz',
            'ort',
            'laender_code',
            'telefon'
        ]) }} as hd_kunde_address,
        strasse_hsnr,
        plz,
        ort,
        laender_code,
        telefon,
        load_ts,
        'stg_kunden' as record_source
    from {{ ref('stg_kunden') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where CONCAT(hk_kunde, hd_kunde_address) not in (
    select CONCAT(hk_kunde, hd_kunde_address) from {{ this }}
)
{% endif %}