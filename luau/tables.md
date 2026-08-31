TITLE: Luau Tables and Data Structures
CATEGORY: luau
PRIORITY: A
SOURCE: Luau Spec
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Tables are Luau's sole data structuring container (arrays, dictionaries, sets, objects, metatables). Utilizing proper iteration methods, memory pre-allocation, and reuse (`table.clear`) is vital for optimal runtime performance.

TABLE_MODES:
- Array Mode (Sequences): Contiguous integer indices `[1..N]`. Length `#tbl` works. Iterate via `ipairs` or `for i = 1, #tbl do`.
- Dictionary Mode (Hash Maps): Non-contiguous keys (strings, instances, tables). Length `#tbl` DOES NOT WORK! Iterate via `pairs`.

BUILT-IN TABLE APIS:
- `table.insert(tbl, [pos], val)`: Appends or inserts value.
- `table.remove(tbl, [pos])`: Removes element and shifts array indices down.
- `table.clear(tbl)`: Clears all keys/values while retaining allocated capacity. (Fast memory reuse!).
- `table.create(count, [val])`: Pre-allocates array memory capacity.
- `table.clone(tbl)`: Creates shallow copy.
- `table.freeze(tbl)`: Makes table read-only.

WHEN_TO_USE:
- Storing collections, inventories, configuration settings, or object lookup maps.

WHEN_NOT_TO_USE:
- Do not instantiate new `{}` tables inside tight 60 FPS loops when a static buffer table can be cleared via `table.clear()`.

CORE_RULES:
- Use `table.clear(tbl)` to reset reusable buffer tables inside loops.
- Use `ipairs` or numeric `for` for arrays; use `pairs` for dictionaries.
- Never use `#tbl` to measure dictionary size.
- Pre-allocate table sizes using `table.create(capacity)` when generating large arrays.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `table.clear`, `table.create`, `table.insert`, `table.remove`, `table.clone`, `table.freeze`, `ipairs`, `pairs`.
  CONTEXT_DEPENDENT: `table.remove()` shifts element indices, changing length `#tbl` immediately.
  DO_NOT_ASSUME: `#tbl` returns dictionary key count (it only counts contiguous integer indices starting at 1).

ANTI_PATTERNS:

BAD:
```lua
RunService.Heartbeat:Connect(function()
    local tempBuffer = {} -- BAD: Allocating new table 60 FPS!
end)
```
WHY_BAD: Allocates new table memory every frame, causing garbage collection spikes.
BETTER:
```lua
local tempBuffer = {}
RunService.Heartbeat:Connect(function()
    table.clear(tempBuffer) -- BETTER: Reuses memory capacity
end)
```

PERFORMANCE:
`table.clear()` is C-native and up to 10x faster than creating new `{}` tables. Numeric `for i = 1, #array do` is faster than `ipairs` in Luau VM.

SECURITY_AND_TRUST_BOUNDARY:
Use `table.freeze()` on shared configuration tables to prevent external code from mutating runtime settings.

LIFECYCLE_AND_CLEANUP:
Clear table entries or call `table.clear(tbl)` when cache objects leave.

RELATED:
luau/types
luau/functions
patterns/cache

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Managing data collections, array buffers, cache tables.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Primitive scalars.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Designing data buffers, caches, inventory tables, or queue structures.
- Iterating array sequences vs dictionary maps.
THAI_KEYWORDS: ตาราง, อาร์เรย์, ดิพชันนารี, ข้อมูล, วนลูป, เคลียร์, table, array, dictionary, pairs, ipairs, clear
PREFER: `table.clear(buffer)` for recycling temporary tables inside loops.
AVOID: Using `#dict` to count dictionary key-value pairs.
DO_NOT_ASSUME: `table.clone()` performs a deep recursive copy (it is a shallow copy).
RELATED_KNOWLEDGE: luau/types, patterns/cache
