-- models/raw_vault/sat_<entity>_<thema>.sql
{{ config(unique_key=['hk_kunde', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['kunde_id']) }} as hk_kunde,
        {{ get_hash_diff([
            'kundentyp',
            'nachname',
            'vorname',
            'firmenname',
            'ust_id',
            'geburtsdatum',
            'geschlecht'
        ]) }} as hd_kunde_basis,
        kundentyp,
        nachname,
        vorname,
        firmenname,
        ust_id,
        geburtsdatum,
        geschlecht,
        load_ts,
        erstellt_am,
        geaendert_am,
        'stg_kunden' as record_source
    from {{ ref('stg_kunden') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where CONCAT(hk_kunde, hd_kunde_basis) not in (
    select CONCAT(hk_kunde, hd_kunde_basis) from {{ this }}
)
{% endif %}