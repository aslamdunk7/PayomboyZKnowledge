TITLE: Caching Pattern
CATEGORY: patterns
PRIORITY: S
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Caching stores reusable calculation results, lookup queries, or stable instance references in memory to eliminate expensive, repetitive operations (such as traversing the DataModel tree or re-calculating heavy spatial data).

WHEN_TO_USE:
- The same Instance or query result is accessed repeatedly in high-frequency loops.
- Expensive search queries (`workspace:FindFirstChild()`) are executed constantly.
- Source data changes less frequently than it is read.

WHEN_NOT_TO_USE:
- Data changes continuously every frame (caching provides no value and risks serving stale data).
- Objects can be destroyed without an event mechanism to invalidate the cache.

CORE_RULES:
- Always pair caches with invalidation mechanisms (event-driven or time-to-live).
- Use `ChildAdded`/`ChildRemoved` to keep instance caches updated dynamically.
- Clear cached references when target objects are destroyed.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `ChildAdded`, `ChildRemoved`, `Destroying`, `table.clear(cache)`.
  CONTEXT_DEPENDENT: Holding a cached instance reference prevents GC only if the instance is not destroyed; destroyed instances in cache evaluate as stale.
  DO_NOT_ASSUME: A cached instance reference stays valid after the instance is destroyed.

INVALIDATION STRATEGIES:
- Event-Based: Listen to `ChildAdded`/`ChildRemoved` or `Destroying`.
- Time-to-Live (TTL): Auto-refresh after `X` seconds.
- Explicit Refresh: Provide a `:Refresh()` function.

ANTI_PATTERNS:

BAD:
```lua
RunService.Heartbeat:Connect(function()
    local item = workspace.Folder:FindFirstChild("Chest") -- BAD: Tree lookup 60 times/sec!
end)
```
WHY_BAD: String searching across folder children every frame wastes CPU.
BETTER:
```lua
local cachedChest = workspace.Folder:FindFirstChild("Chest")
workspace.Folder.ChildAdded:Connect(function(c) if c.Name == "Chest" then cachedChest = c end end)
workspace.Folder.ChildRemoved:Connect(function(c) if c == cachedChest then cachedChest = nil end end)
```

PERFORMANCE:
Direct table access (`cache[key]`) executes in ~1-2 nanoseconds versus hundreds of microseconds for engine instance lookups.

SECURITY_AND_TRUST_BOUNDARY:
Verify cached objects exist (`if cachedItem and cachedItem.Parent then`) before accessing properties.

LIFECYCLE_AND_CLEANUP:
Clear cache entries when target instances leave the workspace or game.

RELATED:
roblox/instances
patterns/cleanup
patterns/event-driven

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: High-frequency lookups for players, chests, or mobs.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Single one-off script lookups.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Optimizing high-frequency loops or automation scripts.
- Reducing redundant engine API queries.
THAI_KEYWORDS: แคช, เก็บข้อมูล, ค้นหา, บันทึก, ลืม, cache, store, storage, DataStore
PREFER: Event-driven cache invalidation over continuous polling.
AVOID: Caching instances without an invalidation mechanism.
DO_NOT_ASSUME: A cached Instance reference remains valid after `Destroy()`.
RELATED_KNOWLEDGE: roblox/instances, patterns/cleanup, patterns/event-driven
