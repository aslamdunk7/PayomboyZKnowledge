TITLE: Error Handling Pattern
CATEGORY: patterns
PRIORITY: S
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Robust error handling isolates potential runtime exceptions (network timeouts, missing instances, executor function failures, or bad JSON responses) to prevent script crashes and preserve overall system stability.

ERROR_TYPES:
- Expected Failures: Missing instances, failed raycasts, nil player characters (handle with `if not object then`).
- Execution Exceptions: Executor API missing, `HttpService:JSONDecode` invalid JSON, network drop (handle with `pcall` or `xpcall`).
- Fatal Invariant Breaches: Invalid internal state, invalid arguments passed to core functions (handle with `assert` or `error`).

TOOLS & APIS:
- `pcall(func, ...)`: Executes `func` in protected mode. Returns `(success, result)`.
- `xpcall(func, errHandler, ...)`: Protected call with custom error handler (useful with `debug.traceback`).
- `assert(condition, message)`: Throws error if condition evaluates to `false` or `nil`.
- `warn(...)`: Outputs warning message without stopping thread.

WHEN_TO_USE:
- Calling external web APIs, parsing JSON, executing user scripts, or calling network remotes.

WHEN_NOT_TO_USE:
- Do not use `pcall` as a replacement for standard nil checks (`if instance then`).

CORE_RULES:
- Do NOT blanket-wrap entire scripts in a single massive `pcall`. Wrap only specific atomic operations that risk throwing errors.
- Never swallow errors silently without logging diagnostic context.
- Always perform pre-validation (`if target and target:IsA(...) then`) before relying on `pcall`.
- Ensure resources and locks are cleaned up even if an operation inside `pcall` fails.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `pcall`, `xpcall`, `assert`, `error`, `warn`, `debug.traceback`.
  CONTEXT_DEPENDENT: `pcall` returns `true` + function return values on success, or `false` + error message on failure.
  DO_NOT_ASSUME: `pcall` catches syntax compilation errors (syntax errors prevent script load entirely).

ANTI_PATTERNS:

BAD:
```lua
pcall(function()
    doEverythingInScript() -- BAD: Blanket pcall!
end)
```
WHY_BAD: Silently swallows genuine logic bugs without printing stack traces or error logs.
BETTER:
```lua
local ok, data = pcall(function()
    return HttpService:JSONDecode(rawJson)
end)
if ok and type(data) == "table" then
    processData(data)
else
    warn("[DataEngine] JSON decode failed:", data)
    processData(defaultData)
end
```

PERFORMANCE:
`pcall` in Luau is fast, but invoking it millions of times inside tight 60 FPS loops introduces overhead compared to direct boolean validation.

SECURITY_AND_TRUST_BOUNDARY:
Protected execution prevents malicious payloads or network drops from crashing host scripts.

LIFECYCLE_AND_CLEANUP:
Always release locks or clean up temporary objects in `finally` logic when operations inside `pcall` fail.

RELATED:
patterns/cleanup
patterns/state-machine

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Network calls, JSON decoding, executor API interactions.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Basic table lookups or local variable math.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Calling external APIs (`writefile`, `readfile`, `HttpGet`, `HttpService`).
- Interacting with network remotes, custom executor functions, or dynamic instance loading.
THAI_KEYWORDS: ข้อผิดพลาด, พลาด, ป้องกันสคริปต์ดับ, ตรวจสอบ, ล้มเหลว, error, pcall, xpcall, assert, warn
PREFER: Guard clauses (`if not instance then return end`) over `pcall` for missing objects.
AVOID: Silent `pcall` blocks with empty error callbacks.
DO_NOT_ASSUME: `pcall` catches script compilation syntax errors.
RELATED_KNOWLEDGE: patterns/cleanup, patterns/state-machine
