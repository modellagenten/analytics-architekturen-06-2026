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
    qualify row_number() over (partition by kunde_id order by load_ts desc) = 1
),

stream_latest as (
    select
        stream.kunde_id, 
        kundentyp, 
        nachname, 
        vorname, 
        firmenname,
        strasse_hsnr, 
        plz, 
        ort, 
        telefon,
        stream.event_ts as as_of_ts,
        batch.as_of_ts as most_recent_batch,
        'stream' as quelle
    from {{ ref('stg_kunden_cdc') }} as stream 
    left join (select kunde_id, as_of_ts from batch) as batch on stream.kunde_id = batch.kunde_id
    where op != 'd' and stream.event_ts > batch.as_of_ts
    qualify row_number() over (partition by stream.kunde_id order by stream.lsn desc) = 1
),

unioned as (
    select
        coalesce(stream_latest.kunde_id, batch.kunde_id) as kunde_id,
        coalesce(stream_latest.kundentyp, batch.kundentyp) as kundentyp,
        coalesce(stream_latest.nachname, batch.nachname) as nachname,
        coalesce(stream_latest.vorname, batch.vorname) as vorname,
        coalesce(stream_latest.firmenname, batch.firmenname) as firmenname,
        coalesce(stream_latest.strasse_hsnr, batch.strasse_hsnr) as strasse_hsnr,
        coalesce(stream_latest.plz, batch.plz) as plz,
        coalesce(stream_latest.ort, batch.ort) as ort,
        coalesce(stream_latest.telefon, batch.telefon) as telefon,
        coalesce(stream_latest.as_of_ts, batch.as_of_ts) as as_of_ts
    from batch full outer join stream_latest on batch.kunde_id = stream_latest.kunde_id

)

select * from unioned