{{ config(materialized='view') }}

with batch as (
    select
        kunde_id, 
        kundentyp, 
        nachname, 
        vorname, 
        firmenname,
        strasse_hsnr, 
        plz, 
        ort, 
        telefon,
        load_ts as as_of_ts,
        'batch' as quelle
    from {{ ref('stg_kunden') }}
),

stream_latest as (
    select
        kunde_id, 
        kundentyp, 
        nachname, 
        vorname, 
        firmenname,
        strasse_hsnr, 
        plz, 
        ort, 
        telefon,
        event_ts as as_of_ts,
        'stream' as quelle
    from {{ ref('stg_kunden_cdc') }}
    where op != 'd'
    qualify row_number() over (partition by kunde_id order by lsn desc) = 1
),

unioned as (
    SELECT * FROM batch
    UNION ALL
    SELECT * FROM stream_latest
)
SELECT * FROM unioned
QUALIFY row_number() over (partition by kunde_id order by as_of_ts desc) = 1