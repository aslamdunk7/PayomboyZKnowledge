TITLE: Luau Type System
CATEGORY: luau
PRIORITY: A
SOURCE: Luau Spec (Official Luau Docs)
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Luau extends standard Lua 5.1 with a fast, gradual static type checker. Type annotations, type aliases, union types, and generics improve code correctness and enable IDE autocompletion.

KEY_CONCEPTS:
- Primitive Types: `boolean`, `number`, `string`, `nil`, `any`, `unknown`, `thread`, `buffer`.
- Roblox Types: `Instance`, `Vector3`, `CFrame`, `Color3`, `Player`, `UDim2`.
- Type Annotations: `local count: number = 10`, `local player: Player?` (optional nilable).
- Type Aliases: `type Point = { X: number, Y: number }`.
- Union Types: `type Status = "IDLE" | "RUNNING" | "ERROR"`.

RUNTIME INSPECTION:
- `typeof(value)`: Returns string representation of Luau/Roblox datatype (`"Vector3"`, `"Instance"`, `"table"`, `"number"`). (Prefer `typeof()` in Roblox!).
- `type(value)`: Standard Lua 5.1 type function (returns `"userdata"` or `"table"` for engine types).

WHEN_TO_USE:
- Writing reusable libraries, module interfaces, complex state structures, or runtime type checking.

WHEN_NOT_TO_USE:
- Type annotations are compile-time hints; do not rely on type annotations alone for runtime data validation of network remotes.

CORE_RULES:
- Use `typeof(val)` instead of `type(val)` when evaluating Roblox engine datatypes.
- Use optional type annotations (`T?`) for variables that can legitimately be `nil`.
- Keep generated type annotations consistent with actual values.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `typeof`, `type`, `any`, `unknown`, type aliases, union types, generic type parameters.
  CONTEXT_DEPENDENT: `typeof(Instance)` returns exact class name or `"Instance"`.
  DO_NOT_ASSUME: Type annotations perform automatic runtime coercion or validation.

ANTI_PATTERNS:

BAD:
```lua
if type(object) == "Instance" then end -- BAD: type() returns "userdata"!
```
WHY_BAD: Standard Lua `type()` does not recognize Roblox datatypes.
BETTER:
```lua
if typeof(object) == "Instance" then end -- BETTER: typeof() correctly identifies Roblox datatypes
```

PERFORMANCE:
Type annotations are stripped during Luau bytecode compilation and incur zero runtime performance cost.

SECURITY_AND_TRUST_BOUNDARY:
Always perform explicit runtime checks (`if typeof(val) == "string" then`) when receiving untrusted data from remotes or JSON.

LIFECYCLE_AND_CLEANUP:
Type definitions are static compile-time symbols. No cleanup required.

RELATED:
luau/tables
luau/functions
luau/modules
patterns/error-handling

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Defining data models or runtime type checking.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Primitive mathematical operations.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Writing Luau scripts requiring type annotations or type checking.
- Inspecting runtime datatypes using `typeof()`.
THAI_KEYWORDS: ชนิดข้อมูล, ชนิด, ไทป์, ตรวจสอบไทป์, types, typeof, type, interface
PREFER: `typeof(val)` over `type(val)` in all Roblox/Luau operations.
AVOID: Assuming `type(vector)` returns `"Vector3"`.
DO_NOT_ASSUME: Luau type annotations perform automatic runtime validation.
RELATED_KNOWLEDGE: luau/tables, luau/functions, luau/modules
