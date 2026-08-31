TITLE: Luau ModuleScripts and Architecture
CATEGORY: luau
PRIORITY: A
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
`ModuleScript` instances enable modular, reusable code structure in Roblox. A ModuleScript executes once when first loaded via `require()` and caches its single return value across all subsequent calls within the same execution context.

EXECUTION RULES:
- Single Execution: A `ModuleScript` runs its root code ONLY ONCE when first `require()`-d.
- Return Value: A `ModuleScript` MUST return exactly ONE value (typically a table, function, or class).
- Context Isolation: Requiring a ModuleScript on the Client yields a client-side cached instance; requiring it on the Server yields a separate server-side cached instance.
- Circular Dependencies: If Module A requires Module B, and Module B requires Module A, `require()` throws a fatal error ("Requested module was required recursively").

WHEN_TO_USE:
- Organizing framework services, OOP classes, configuration tables, or shared helper utility libraries.

WHEN_NOT_TO_USE:
- Do not use ModuleScripts to run auto-executing scripts that perform unmanaged side effects on load without explicit initialization methods.

CORE_RULES:
- Never perform uncontrolled side effects (connecting events, creating GUI elements) at root execution when required.
- Provide explicit initialization (`Module.Init()`) or constructor (`Module.new()`) methods instead of automatic side effects.
- Encapsulated private variables inside top-level script scope.
- Decouple shared logic to avoid circular dependencies.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `ModuleScript`, `require`, return table/class, root scope caching.
  CONTEXT_DEPENDENT: Server and Client environments maintain completely separate `require()` cache tables.
  DO_NOT_ASSUME: `require()` re-evaluates the module file when called a second time (it returns the cached table).

ANTI_PATTERNS:

BAD:
```lua
-- Inside ModuleScript root
Players.PlayerAdded:Connect(function(p) print(p.Name) end) -- BAD: Side effect on require!
return {}
```
WHY_BAD: Requiring the module anywhere in the project binds global listeners without caller control.
BETTER:
```lua
local Module = {}
local conn = nil
function Module.Start()
    if not conn then conn = Players.PlayerAdded:Connect(function(p) print(p.Name) end) end
end
function Module.Stop()
    if conn then conn:Disconnect(); conn = nil end
end
return Module
```

PERFORMANCE:
Subsequent `require()` calls return the cached table instance in nanoseconds.

SECURITY_AND_TRUST_BOUNDARY:
Encapsulate private module functions to prevent unauthorized external overrides.

LIFECYCLE_AND_CLEANUP:
Provide explicit `.Stop()` or `:Destroy()` methods on module singletons for clean unloading.

RELATED:
luau/functions
luau/types
patterns/cleanup

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Reusable framework modules and OOP classes.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Single-use linear local scripts.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Designing reusable libraries, system controllers, or script hub modules.
- Structuring clean public APIs vs private encapsulate logic.
THAI_KEYWORDS: มอดูล, สคริปต์มอดูล, โหลดมอดูล, การทำงานซ้ำ, require, ModuleScript, circular dependency
PREFER: Explicit `.Init()` or `.Start()` lifecycle functions over auto-executing code.
AVOID: ModuleScripts performing global state mutations at top-level scope on `require()`.
DO_NOT_ASSUME: `require()` re-evaluates the module file when called a second time.
RELATED_KNOWLEDGE: luau/functions, luau/types, patterns/cleanup
