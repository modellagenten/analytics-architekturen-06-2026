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
    _loaded_at as load_ts
from src
