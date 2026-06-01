{{ config(materialized='view') }}

with raw as (
    select
        message_id,
        publish_time,
        data as event   -- `data` ist bereits JSON-typisiert (Pub/Sub-BQ-Subscription), kein parse_json noetig
    from {{ source('cdc_raw', 'kunden_cdc_events') }}
)

select
    message_id,
    publish_time,
    string(event.op)                                              as op,
    json_value(event, '$.after.kunde_id')                         as kunde_id,
    json_value(event, '$.after.kundentyp')                        as kundentyp,
    json_value(event, '$.after.nachname')                         as nachname,
    json_value(event, '$.after.vorname')                          as vorname,
    json_value(event, '$.after.firmenname')                       as firmenname,
    json_value(event, '$.after.strasse_hsnr')                     as strasse_hsnr,
    json_value(event, '$.after.plz')                              as plz,
    json_value(event, '$.after.ort')                              as ort,
    json_value(event, '$.after.telefon')                          as telefon,
    cast(json_value(event, '$.source.lsn') as int64)              as lsn,
    timestamp_millis(cast(json_value(event, '$.ts_ms') as int64)) as event_ts
from raw
where string(event.source.table) = 'kunden'
