{{ config(materialized='view') }}


with src as (
    select *
    from {{ source('capitol_raw', 'tarife_raw') }}
)

select
    tarif_code,
    monat_nr,
    sparte,
    cast(praemie_monat as numeric) as praemie_monat,
    gueltig_ab,
    geaendert_am,
    _loaded_at as load_ts
from src
