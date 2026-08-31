TITLE: Luau Basics Reference
CATEGORY: luau
PRIORITY: B
SOURCE: Luau Spec
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Foundational reference for Luau syntax conventions, variable declarations, control structures, logical operators, and comment styles.

SYNTAX SUMMARY:
- Variables: `local name = "ValenHub"` (Always use `local` scope!).
- Primitives: Strings (`"text"`, `[[multiline]]`), Numbers (`42`, `3.14`), Booleans (`true`/`false`), Nil (`nil`).
- Control Flow: `if ... elseif ... else ... end`, `for i = 1, 10 do ... end`, `while cond do ... end`, `repeat ... until cond`.
- Logical Operators: `and`, `or`, `not`.
- Luau Inline If Expression: `local val = if condition then optionA else optionB`.

WHEN_TO_USE:
- Reference for basic Luau control flow and syntax structures.

WHEN_NOT_TO_USE:
- Do not use for advanced Roblox engine API decision making (refer to roblox/ directory).

CORE_RULES:
- Always use `local` for variable declarations to prevent global scope pollution.
- Use Luau inline if expressions (`if a then b else c`) instead of old Lua idiom `a and b or c`.
- Never run unbounded `while true do` loops without a `task.wait()` yield.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `local`, `if ... then ... else`, `for`, `while`, `repeat ... until`, inline `if` expression.
  CONTEXT_DEPENDENT: Inline ternary `if a then b else c` evaluates both branches conditionally.
  DO_NOT_ASSUME: Variables created without `local` belong to local block scope (they pollute global scope!).

ANTI_PATTERNS:

BAD:
```lua
x = 10 -- BAD: Global variable!
```
WHY_BAD: Pollutes global table, causing register lookup slowness and bugs across modules.
BETTER:
```lua
local x = 10 -- BETTER: Fast local register variable
```

PERFORMANCE:
Local variables compile directly to fast Luau VM register instructions.

SECURITY_AND_TRUST_BOUNDARY:
Strict local scoping prevents unauthorized global variable tampering.

LIFECYCLE_AND_CLEANUP:
Local variables drop out of scope automatically when block execution finishes.

RELATED:
luau/types
luau/functions
luau/tables

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Basic variable declaration and conditional expressions.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Complex OOP frameworks.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Checking basic Luau control flow and syntax rules.
THAI_KEYWORDS: พื้นฐาน, ไวยากรณ์, ตัวแปร, ลูป, เงื่อนไข, basics, syntax, local, if, for, while
PREFER: Luau ternary `if cond then val1 else val2` syntax.
AVOID: Global variables without `local`.
RELATED_KNOWLEDGE: luau/types, luau/functions
