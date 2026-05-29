# Capitol DWH - dbt-Projekt

Dieses dbt-Projekt liegt **bewusst doppelt** vor:

- **Hier im Repo** (`schulungsumgebung/analytics-architekturen/dbt_project/`) als **Skelett & Referenz** für Trainer/TN, damit ihr ohne GitHub-Login die Struktur sehen könnt.
- In einem **eigenen GitHub-Repository** `capitol-dwh-dbt`, das die TN in **dbt Cloud** einbinden (Fork + Repo-Verbindung).

> Quelle der Wahrheit für die Übungen ist das **GitHub-Repo** - ab dem Moment, in dem ihr es geforkt habt, arbeitet ihr nur noch dort (über die dbt Cloud IDE).

---

## Projekt-Struktur

```
dbt_project/
├── dbt_project.yml             # Projekt-Konfiguration (Layer + Schemata)
├── packages.yml                # dbt_utils 1.3.3
├── profiles.example.yml        # Beispiel für lokale dbt-Core-Nutzung
├── macros/
│   ├── get_hash_key.sql        # MD5-Hash über Business Keys (Hub/Link)
│   └── get_hash_diff.sql       # MD5-Hash über Satellite-Spalten
├── models/
│   ├── sources/
│   │   └── _capitol_sources.yml    # ALLE 4 Quellen + Tests (vorgegeben)
│   ├── staging/                    # Block 2 - Skelette + TODOs
│   ├── raw_vault/                  # Block 3 - LEER, von TN selbst befüllt
│   ├── business_vault/             # Block 3 - LEER (optional)
│   └── marts/                      # Block 5 - LEER
└── snapshots/                      # optional, in Übung 2 (C)
```

> **Wichtig:** Für **Übung 3 (Data Vault)** liegen unter `models/raw_vault/`
> bewusst **keine Skelette**. Jede Gruppe legt ihre Dateien (Hubs, Links, Sats)
> selbst an - Namenskonventionen siehe unten.

---

## Setup-Pfad in der Schulung

### Variante A - dbt Cloud (empfohlen, Standard)

1. Trainer stellt das **GitHub-Repo** `capitol-dwh-dbt` zur Verfügung (Vorlage = dieser Ordner).
2. TN forkt das Repo in den eigenen GitHub-Account.
3. dbt Cloud -> **Account Settings -> Projects -> New Project**
   - Connection: BigQuery – euer **persönliches Keyfile** (`dbt-cloud-tNN-key.json`) hochladen
   - Repository: das gemeinsame GitHub-Repo (bzw. euer Fork)
   - Development Credentials -> **Dataset: `tn_pNN`** (euer persönliches Dataset)
4. Im Develop-Tab: `dbt deps` -> `dbt debug` -> muss „All checks passed" zeigen.
5. Ab jetzt arbeitet ihr in der **dbt Cloud Browser-IDE**.

### Variante B - dbt Core lokal (optional)

```bash
cd schulungsumgebung/analytics-architekturen/dbt_project

# profiles.example.yml als Vorlage nach ~/.dbt/profiles.yml kopieren
cp profiles.example.yml ~/.dbt/profiles.yml

# Service-Account-Keyfile vom Trainer ablegen, Pfad in profiles.yml anpassen
# Optional: GCP_PROJECT-Env setzen, sonst Default 'capitol-schulung'

dbt deps
dbt debug
```

---

## Sources

In `models/sources/_capitol_sources.yml` sind **alle vier** Capitol-Quellen vorab deklariert:

| Source-Tabelle | Beladen durch | Gruppe |
|---|---|---|
| `capitol_raw.vertraege_raw` | `load_scripts/load_vertraege.py` | A |
| `capitol_raw.schaden_events_raw` | `load_scripts/load_schaden_events.py` | B |
| `capitol_raw.kunden_raw` | `load_scripts/load_kunden.py` | C |
| `capitol_raw.tarife_raw` | `load_scripts/load_tarife.py` | D |

Die Source `capitol_raw` zeigt auf das **feste, gemeinsame BigQuery-Dataset `capitol_raw`** (read-only, vom Trainer befüllt). Gebaut wird dagegen ins persönliche Dataset (`tn_pNN`), das ihr in den dbt-Cloud-Development-Credentials setzt.

---

## Übungen mit diesem Projekt

| Block | Übung | Schwerpunkt |
|---|---|---|
| 2 | `stg_*` vervollständigen (TODOs im SQL) | Staging-Modelle + Tests |
| 3 | Hubs/Links/Sats unter `models/raw_vault/` | Data Vault händisch (mit Macros) |
| 5 | `dim_*` / `fct_*` unter `models/marts/` | Star Schema |

---

## Konventionen (allgemein)

- **Schema-Namen** ergeben sich aus eurem Dev-Dataset + Layer-Suffix (z.B. `tn_p01_staging`, `tn_p01_marts`).
- **Materialization** pro Layer in `dbt_project.yml`.
- **Tests** liegen neben dem Modell in einer YAML mit Prefix `_`.
- **Quellen** werden ausschließlich über `source()` referenziert - niemals harte Tabellennamen.

---

## Konventionen Data Vault (Block 3)

**Datei- und Tabellennamen**

| Typ | Präfix | Beispiel |
|---|---|---|
| Hub | `hub_<entity>` | `hub_vertrag` |
| Link | `link_<entity_a>_<entity_b>` | `link_vertrag_kunde` |
| Satellit | `sat_<entity>_<thema>` | `sat_vertrag_basis`, `sat_kunde_adresse` |
| Effectivity-Sat | `eff_sat_<link_name>` | `eff_sat_schaden_vertrag` |
| Multi-Active-Sat | `mas_<entity>_<thema>` | `mas_tarif_kondition` |

**Pflicht-Spalten (alle DV-Tabellen)**

| Spalte | Typ | Bedeutung |
|---|---|---|
| `hk_<entity>` | STRING | Hash-Key (Hubs/Sats) |
| `hk_l_<link>` | STRING | Hash-Key des Links |
| `<bk_col(s)>` | - | Business Key(s) im Hub |
| `hd_<sat_name>` | STRING | Hash-Diff (nur Satelliten) |
| `load_ts` | TIMESTAMP | Lade-Zeitpunkt (aus `_loaded_at` / `event_ts`) |
| `record_source` | STRING | Quelle, z.B. `'stg_vertraege'` |

**Hash-Macros (`macros/`)**

```sql
{{ get_hash_key(['vsnr']) }}                        -- Hub-Hash
{{ get_hash_key(['vertrag_id', 'kunde_id']) }}      -- Link-Hash
{{ get_hash_diff(['tarif_code', 'praemie_jahres_eur']) }}  -- Sat-Hash-Diff
```

Beide Macros normalisieren intern (`UPPER` + `TRIM` + `NULL -> '^^'`) und liefern
einen **MD5-Hex-String in Großbuchstaben**. So sind die Hashes konsistent über
Hubs/Links/Sats hinweg.

**Insert-Only-Pattern für Hubs/Links** (Standard-Snippet, von Hand geschrieben)

```sql
{{ config(materialized='incremental', schema='raw_vault', unique_key='hk_vertrag') }}

with src as (
    select
        {{ get_hash_key(['vsnr']) }} as hk_vertrag,
        vsnr,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
)

select * from src
{% if is_incremental() %}
where hk_vertrag not in (select hk_vertrag from {{ this }})
{% endif %}
```

**Insert-Only-Pattern für Satelliten mit Hash-Diff**

```sql
{{ config(materialized='incremental', schema='raw_vault') }}

with src as (
    select
        {{ get_hash_key(['vsnr']) }} as hk_vertrag,
        {{ get_hash_diff(['tarif_code', 'beginn_datum', 'praemie_jahres_eur']) }} as hd_vertrag_basis,
        tarif_code, beginn_datum, praemie_jahres_eur,
        load_ts,
        'stg_vertraege' as record_source
    from {{ ref('stg_vertraege') }}
)

select * from src
{% if is_incremental() %}
where (hk_vertrag, hd_vertrag_basis) not in (
    select hk_vertrag, hd_vertrag_basis from {{ this }}
)
{% endif %}
```

> **Faustregel:** *Im DV gibt es kein UPDATE und kein DELETE.* Jede inhaltliche
> Änderung erzeugt einen neuen Sat-Eintrag mit aktuellem `load_ts`.
