{{ config(unique_key=['hk_schaden', 'load_ts']) }}

with src as (
    select distinct
        {{ get_hash_key(['schaden_id']) }} as hk_schaden,
        sum(schaden_summe_eur) over (partition by schaden_id) as schaden_summe_gesamt_eur,
        load_ts,
        'stg_schaden_events' as record_source
    from {{ ref('stg_schaden_events') }}
    where event_typ = 'MELDUNG' 
),
src2 as (
    select *,
        {{ get_hash_diff([
            'schaden_summe_gesamt_eur'
        ]) }} as hd_schaden_schadensumme,
    from src
)

select * from src2
{% if is_incremental() %}
-- nur neue inhaltliche Stände einfügen
where concat(hk_schaden, hd_schaden_schadensumme) not in (
    select concat(hk_schaden, hd_schaden_schadensumme) from {{ this }}
)
{% endif %}