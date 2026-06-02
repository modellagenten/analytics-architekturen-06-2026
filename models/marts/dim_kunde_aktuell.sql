-- models/marts/dim_kunde_aktuell.sql
{{ config(materialized='view') }}

with hwm as (
    select max(load_ts) as batch_cutoff from {{ref("stg_kunden")}}
),

batch as (
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
    from {{ ref('stg_kunden_cdc') }} c, hwm
    where op != 'd' and c.event_ts > hwm.batch_cutoff
    qualify row_number() over (partition by kunde_id order by lsn desc) = 1
),

unioned as(
    SELECT *
    FROM batch

    UNION DISTINCT

    SELECT *
    FROM stream_latest
)

SELECT *
FROM unioned u1
WHERE NOT EXISTS (select kunde_id from unioned u2 where u2.as_of_ts > u1.as_of_ts AND u1.kunde_id=u2.kunde_id)