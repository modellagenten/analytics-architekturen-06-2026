{#
  get_hash_key – berechnet einen MD5-Hash über eine Liste von Business-Key-Spalten.

  Konventionen (DV 2.1):
  - Normalisierung: TRIM + UPPER, NULL -> '^^'
  - Trennzeichen zwischen Spalten: '||'
  - Ergebnis: MD5 in Großbuchstaben

  Verwendung:
      {{ get_hash_key(['vsnr']) }}                       -> Hub-Key
      {{ get_hash_key(['vertrag_id', 'kunde_id']) }}     -> Link-Key

  Hinweise:
  - MD5 reicht für die Schulung; in Produktion mit Compliance-Druck ggf. SHA-256.
  - Niemals harte Tabellennamen verwenden – Spalten werden im SELECT-Kontext aufgelöst.
#}
{% macro get_hash_key(columns) %}
    upper(to_hex(md5(concat(
        {% for col in columns -%}
            coalesce(upper(trim(cast({{ col }} as string))), '^^')
            {%- if not loop.last %}, '||', {% endif %}
        {%- endfor %}
    ))))
{% endmacro %}

-- {{get_hash_key(['a'])}}