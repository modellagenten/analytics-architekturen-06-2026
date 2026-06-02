-- models/marts/dim_kunde_aktuell.sql
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
        0 as lsn,
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
        lsn,
        event_ts as as_of_ts,
        'stream' as quelle
    from {{ ref('stg_kunden_cdc') }}
    where op != 'd'
    qualify row_number() over (partition by kunde_id order by lsn desc) = 1
),

unioned as (
    select * from batch
    union all
    select * from stream_latest
),

deduped as (
    select * EXCEPT (lsn)
    from unioned
    qualify row_number() over (
        partition by kunde_id
        order by lsn desc, as_of_ts desc
    ) = 1
)

select * from deduped