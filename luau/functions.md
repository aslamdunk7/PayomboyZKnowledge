TITLE: Luau Functions and Contracts
CATEGORY: luau
PRIORITY: A
SOURCE: Luau Spec
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Functions are first-class values in Luau. Designing explicit function contracts (inputs, return values, side effects, error behavior), leveraging local scoping, and avoiding closure allocations in loops are essential for performance.

FUNCTION_TYPES & PATTERNS:
- Local Functions: Scoped strictly to enclosing block. Fast lookup via local registers (`local function calc()`).
- Anonymous Closures: Functions defined inline (`function() ... end`). Allocates new memory closure each execution.
- Variadic Functions: Accepts variable arguments using `...` and `select(...)`.
- Methods (Colon Notation): `object:method(...)` implicitly passes `self` as 1st argument.

FUNCTION CONTRACT MATRIX:
- Explicit Inputs: Specify required types and handle default arguments (`param or default`).
- Explicit Outputs: Return predictable types or `(boolean, string)` tuples for operation results.
- Side Effects: Document state modifications (e.g. cache updates, network remotes).
- Error Guarantees: Specify whether function throws errors or returns `nil`/`false` on failure.

WHEN_TO_USE:
- Modularizing code, callbacks, metatable methods, or system utility functions.

WHEN_NOT_TO_USE:
- Do not wrap single-line expressions in unnecessary function closures inside loops.

CORE_RULES:
- Declare functions as `local function name()` rather than global `function name()`.
- Avoid creating anonymous functions inside tight loops (`while` / `Heartbeat`); reuse named functions.
- Use guard clauses (`if not valid then return end`) to flatten nested conditional trees.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `local function`, closures, variadics (`...`), methods (`:`), guard clauses.
  CONTEXT_DEPENDENT: Anonymous closures defined inside loops create new memory objects on every iteration.
  DO_NOT_ASSUME: Global functions defined without `local` are garbage collected when local scope exits.

ANTI_PATTERNS:

BAD:
```lua
function doWork() end -- BAD: Global function!
```
WHY_BAD: Contaminates global environment (`_G`), causing slower register lookups.
BETTER:
```lua
local function doWork() end -- BETTER: Local register lookup
```

BAD:
```lua
RunService.Heartbeat:Connect(function()
    local process = function(item) return item.Value * 2 end -- BAD: Closure allocation 60 FPS!
end)
```
WHY_BAD: Allocates a new closure table in memory every frame step.
BETTER: Move function definition outside the frame loop.

PERFORMANCE:
Local functions compile directly to fast register operations in Luau VM. Guard clauses reduce instruction jump overhead.

SECURITY_AND_TRUST_BOUNDARY:
Encapsulate private module functions to prevent external unauthorized modification.

LIFECYCLE_AND_CLEANUP:
Callbacks attached to signals must be disconnected when feature is disabled.

RELATED:
luau/types
luau/tables
luau/modules
patterns/error-handling

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Modular helper functions and callbacks.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Single-line inline operations.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Writing or refactoring functions, callbacks, or helper modules.
- Flattening deeply nested code using guard clauses.
THAI_KEYWORDS: ฟังก์ชัน, เมธอด, พารามิเตอร์, ตัวแปรท้องถิ่น, คอลแบ็ก, function, local, callback, method
PREFER: `local function name()` syntax for all module functions.
AVOID: Global functions without `local`.
DO_NOT_ASSUME: Functions defined inside loops reuse the same memory reference.
RELATED_KNOWLEDGE: luau/types, luau/modules, patterns/error-handling
