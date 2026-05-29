{{ config(materialized='view') }}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │ Gruppe C – Staging Kunden                                        │
-- │ Quelle: source('capitol_raw', 'kunden_raw')                      │
-- │                                                                  │
-- │ TODO (Übung 2):                                                  │
-- │  1. Anzeige-Name: bei Firmen firmenname, sonst vorname + nachname│
-- │  2. PLZ als STRING (führende Nullen erhalten!)                   │
-- │  3. is_firmenkunde-Flag aus kundentyp ableiten                   │
-- │  4. Test 'unique' + 'not_null' auf kunde_id in YAML              │
-- │  5. Test 'accepted_values' auf kundentyp (P, F)                  │
-- └──────────────────────────────────────────────────────────────────┘

with src as (
    select *
    from {{ source('capitol_raw', 'kunden_raw') }}
)

select
    kunde_id,
    kundentyp,
    -- TODO: kundentyp = 'F' as is_firmenkunde,
    -- TODO: coalesce(firmenname, concat_ws(' ', vorname, nachname)) as anzeige_name,
    nachname,
    vorname,
    firmenname,
    ust_id,
    geburtsdatum,
    geschlecht,
    strasse_hsnr,
    cast(plz as string) as plz,
    ort,
    laender_code,
    telefon,
    erstellt_am,
    geaendert_am,
    _loaded_at as load_ts
from src
