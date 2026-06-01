{{ config(
    materialized='incremental',
    unique_key='schaden_event_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}


with src as (
    select *
    from {{ source('capitol_raw', 'schaden_events_raw') }}
)

select
    schaden_event_id,
    schaden_id,
    vertrag_id,
    event_typ,
    cast(schaden_summe_eur as numeric) as schaden_summe_eur,
    payload,
    _loaded_at as load_ts,
    JSON_VALUE(JSON_VALUE(payload), '$.kurz_beschreibung') as kurzb,
    JSON_VALUE(JSON_VALUE(payload), '$.sachbearbeiter') as sachb,
    JSON_VALUE(JSON_VALUE(payload), '$.sparte') as sparte,
from src