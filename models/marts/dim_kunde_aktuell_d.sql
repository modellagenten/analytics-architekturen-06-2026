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
        'u' as op,
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
        op,
        'stream' as quelle
    from {{ ref('stg_kunden_cdc') }}
    qualify row_number() over (partition by kunde_id order by lsn desc, publish_time desc) = 1
),

unioned as (
    SELECT * FROM batch
    UNION ALL
    SELECT * FROM stream_latest
)
SELECT * FROM unioned
WHERE op != 'd'
QUALIFY row_number() over (partition by kunde_id order by as_of_ts desc) = 1