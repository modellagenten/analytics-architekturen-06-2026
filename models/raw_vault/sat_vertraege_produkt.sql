{{ config(unique_key=['hk_vertraege', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['vertrag_id']) }} as hk_vertraege,
        {{ get_hash_diff([
            'tarif_code',
            'produkt_name'
        ]) }} as hd_vertraege_produkt,
        tarif_code,
        produkt_name,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where CONCAT(hk_vertraege, hd_vertraege_produkt) not in (
    select CONCAT(hk_vertraege, hd_vertraege_produkt) from {{ this }}
)
{% endif %}