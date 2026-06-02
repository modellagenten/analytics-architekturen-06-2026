{{ config(unique_key=['hk_schaden', 'load_ts']) }}

with src as (
    select
        {{ get_hash_key(['schaden_id']) }} as hk_schaden,
        {{ get_hash_diff([
            'kurz_beschreibung',
            'sachbearbeiter',
            'sparte'
        ]) }} as hd_schaden_payload,
        kurz_beschreibung,
        sachbearbeiter,
        sparte, 
        load_ts,
        'stg_schaden_events' as record_source
    from {{ ref('stg_schaden_events') }}
    qualify row_number() over (partition by schaden_id order by load_ts desc) = 1
)

select * from src
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where concat(hk_schaden, hd_schaden_payload) not in (
    select concat(hk_schaden, hd_schaden_payload) from {{ this }}
)
{% endif %}