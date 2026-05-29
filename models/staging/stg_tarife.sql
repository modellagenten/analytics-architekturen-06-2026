{{ config(materialized='view') }}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │ Gruppe D – Staging Tarife                                        │
-- │ Quelle: source('capitol_raw', 'tarife_raw')                      │
-- │                                                                  │
-- │ TODO (Übung 2):                                                  │
-- │  1. Praemie_monat als NUMERIC(10,2)                              │
-- │  2. monat_nr als INT (1..12) validieren                          │
-- │  3. quartal aus monat_nr ableiten (1-3 Q1, 4-6 Q2, ...)          │
-- │  4. Test 'relationships' auf tarif_code zu stg_vertraege         │
-- │  5. Test 'unique' auf Kombi (tarif_code, monat_nr) in YAML       │
-- └──────────────────────────────────────────────────────────────────┘

with src as (
    select *
    from {{ source('capitol_raw', 'tarife_raw') }}
)

select
    tarif_code,
    monat_nr,
    -- TODO: case when monat_nr between 1 and 3 then 'Q1' ... end as quartal,
    sparte,
    cast(praemie_monat as numeric) as praemie_monat,
    gueltig_ab,
    geaendert_am,
    _loaded_at as load_ts
from src
