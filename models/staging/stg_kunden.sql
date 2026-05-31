{{ config(materialized='view') }}

with src as (
    select *
    from {{ source('capitol_raw', 'kunden_raw') }}
)

select
    kunde_id,
    kundentyp,
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
