{{ config(unique_key=['hk_vertraege', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['vertrag_id']) }} as hk_vertraege,
        {{ get_hash_diff([
            'beginn_datum',
            'ende_datum',
            'status_code',
            'storno_flag'
        ]) }} as hd_vertraege_gueltigkeit,
        beginn_datum,
        ende_datum,
        status_code,
        storno_flag,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where CONCAT(hk_vertraege, hd_vertraege_gueltigkeit) not in (
    select CONCAT(hk_vertraege, hd_vertraege_gueltigkeit) from {{ this }}
)
{% endif %}