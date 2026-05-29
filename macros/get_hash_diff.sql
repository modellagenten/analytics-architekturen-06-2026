{#
  get_hash_diff – berechnet einen MD5-Hash über die fachlichen Satellite-Spalten.

  Pattern (DV 2.1):
  - Wird im Satelliten gespeichert
  - Vergleich `aktueller_hash_diff` vs. `letzter_hash_diff` pro Hub-Key
  - Bei Gleichheit: kein neuer Sat-Eintrag

  Verwendung:
      {{ get_hash_diff([
          'tarif_code', 'beginn_datum', 'praemie_jahres_eur'
      ]) }}
#}
{% macro get_hash_diff(columns) %}
    upper(to_hex(md5(concat(
        {% for col in columns -%}
            coalesce(upper(trim(cast({{ col }} as string))), '^^')
            {%- if not loop.last %}, '||', {% endif %}
        {%- endfor %}
    ))))
{% endmacro %}
