{{ config(materialized='view') }}


with src as (
    select *
    from {{ source('capitol_raw', 'vertraege_raw') }}
)

select
    vertrag_id,
    vsnr,
    kunde_id,
    tarif_code,
    vermittler_code,
    produkt_name,
    beginn_datum,
    ende_datum,
    CAST(praemie_jahres_eur as decimal) AS praemie_jahres_eur,
    UPPER(status_code) AS status_code,
    (CASE WHEN status_code = 'S' THEN 1 ELSE 0 END) AS storno_flag,
    _loaded_at as load_ts
from src
