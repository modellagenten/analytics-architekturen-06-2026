{{ config(materialized='view') }}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │ Gruppe A – Staging Verträge                                      │
-- │ Quelle: source('capitol_raw', 'vertraege_raw')                   │
-- │                                                                  │
-- │ TODO (Übung 2):                                                  │
-- │  1. Status_code auf Großbuchstaben normalisieren                 │
-- │  2. Datums-Spalten sauber casten                                 │
-- │  3. Jahres-Prämie als NUMERIC(12,2)                              │
-- │  4. Spalte storno_flag (True wenn status_code='S') ergänzen      │
-- │  5. Technische Spalte _loaded_at als load_ts übernehmen          │
-- └──────────────────────────────────────────────────────────────────┘

with src as (
    select *
    from {{ source('capitol_raw', 'vertraege_raw') }}
)

select
    vertrag_id,
    vsnr,
    kunde_id,
    tarif_code,
    -- TODO: cast(beginn_datum as date) as beginn_datum,
    -- TODO: cast(ende_datum as date) as ende_datum,
    -- TODO: cast(praemie_jahres_eur as numeric) as praemie_jahres_eur,
    -- TODO: upper(status_code) as status_code,
    -- TODO: status_code = 'S' as storno_flag,
    vermittler_code,
    produkt_name,
    _loaded_at as load_ts
from src
