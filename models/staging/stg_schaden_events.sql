{{ config(
    materialized='incremental',
    unique_key='schaden_event_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │ Gruppe B – Staging Schaden-Events                                │
-- │ Quelle: source('capitol_raw', 'schaden_events_raw')              │
-- │                                                                  │
-- │ TODO (Übung 2):                                                  │
-- │  1. event_ts als TIMESTAMP casten                                │
-- │  2. JSON-Felder aus payload extrahieren                          │
-- │     (kurz_beschreibung, sachbearbeiter, sparte)                  │
-- │  3. is_incremental()-Block aktivieren                            │
-- │  4. Test 'unique' + 'not_null' auf schaden_event_id in YAML      │
-- └──────────────────────────────────────────────────────────────────┘

with src as (
    select *
    from {{ source('capitol_raw', 'schaden_events_raw') }}
)

select
    schaden_event_id,
    schaden_id,
    vertrag_id,
    -- TODO: cast(event_ts as timestamp) as event_ts,
    event_typ,
    cast(schaden_summe_eur as numeric) as schaden_summe_eur,
    -- TODO: json_value(payload, '$.kurz_beschreibung') as kurz_beschreibung,
    -- TODO: json_value(payload, '$.sachbearbeiter') as sachbearbeiter,
    -- TODO: json_value(payload, '$.sparte') as sparte,
    payload,
    _loaded_at as load_ts
from src

{% if is_incremental() %}
    -- TODO: nur neue Events laden, z.B.:
    -- where event_ts > (select coalesce(max(event_ts), timestamp '1970-01-01') from {{ this }})
{% endif %}
