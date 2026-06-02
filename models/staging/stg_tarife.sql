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
    concat('Q', cast(ceil(monat_nr / 3.0) as {{ dbt.type_string() }})) quartal,
    gueltig_ab,
    geaendert_am,
    _loaded_at as load_ts
from src
