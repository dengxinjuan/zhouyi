# Hexagram data

- **Source (classical text):** [Chinese Text Project — Book of Changes](https://ctext.org/book-of-changes) (周易). Digital base: 武英殿十三經注疏本《周易正義》.
- **English translation (judgment / reference):** James Legge (public domain), via ctext.org.
- **Schema:** `hexagrams.json` has root `_meta` (binary_convention, version) and `hexagrams` array. Each entry: `id`, `name_cn`, `name_en`, `binary` (6 chars, **bottom→top**: first char = 初爻, last = 上爻; `"1"` = yang/solid, `"0"` = yin/broken), `classical` (judgment_cn, lines_cn), `modern` (summary_cn/en, lines_explained_cn/en).
