TITLE: Luau Event Signals and Callbacks
CATEGORY: luau
PRIORITY: A
SOURCE: Roblox Creator Docs & Luau Spec
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Event signals (`RBXScriptSignal`) and custom event implementations facilitate publish-subscribe communication across decoupled systems. Understanding callbacks, signal connections, listener dispatching, and custom Signal implementations enables clean event-driven architecture.

ROBLOX SIGNAL APIS:
- `signal:Connect(callback)`: Binds callback to run whenever signal is emitted. Returns `RBXScriptConnection`.
- `signal:Once(callback)`: Binds callback to run ONLY ONCE for next emission, then auto-disconnects.
- `signal:Wait()`: Yields calling thread until signal is emitted next, returning emitted arguments.

CUSTOM LUAU SIGNAL IMPLEMENTATION:
```lua
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(fn)
    table.insert(self._listeners, fn)
    return {
        Disconnect = function()
            local idx = table.find(self._listeners, fn)
            if idx then table.remove(self._listeners, idx) end
        end
    }
end

function Signal:Fire(...)
    for _, fn in ipairs(self._listeners) do
        task.spawn(fn, ...)
    end
end
```

WHEN_TO_USE:
- Decoupling communication between separate client/server modules using publish-subscribe model.

WHEN_NOT_TO_USE:
- Direct tight function calls where direct return values are expected immediately.

CORE_RULES:
- Always capture `RBXScriptConnection` returned by `:Connect()` to enable clean disconnection.
- Use `signal:Once(fn)` for one-time initialization triggers.
- Do not block signal dispatcher threads with long-yielding operations; wrap long work in `task.spawn()`.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `Connect`, `Once`, `Wait`, `Disconnect`, `Fire`, `RBXScriptSignal`, `RBXScriptConnection`.
  CONTEXT_DEPENDENT: `signal:Wait()` yields the calling thread until the signal fires.
  DO_NOT_ASSUME: Event callbacks execute in a guaranteed sequence order when multiple listeners exist.

ANTI_PATTERNS:

BAD:
```lua
Button.MouseButton1Click:Connect(function()
    task.wait(10) -- BAD: Long yield inside callback!
    doSomething()
end)
```
WHY_BAD: Long yields inside synchronous event handlers delay subsequent signal processing.
BETTER: Wrap long work in `task.spawn(function() task.wait(10); doSomething() end)`.

PERFORMANCE:
Native Roblox signals dispatch in C++ VM; custom Luau signals using `task.spawn` isolate listener exceptions safely.

SECURITY_AND_TRUST_BOUNDARY:
Isolate custom signal callbacks to prevent failing listeners from crashing publisher routines.

LIFECYCLE_AND_CLEANUP:
Disconnect event listeners when features toggle off or target instances are destroyed.

RELATED:
patterns/event-driven
patterns/cleanup
roblox/runservice

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Custom module events and Roblox signal subscriptions.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Direct synchronous math calls.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Implementing custom pub-sub event systems.
- Subscribing to Roblox engine signals (`RBXScriptSignal`).
THAI_KEYWORDS: สัญญาณ, ตัวรับสัญญาณ, คอลแบ็ก, เชื่อมต่อ, ซิกแนล, Connect, Signal, Callback, Disconnect
PREFER: `:Once()` over `:Connect()` for one-time initialization handlers.
AVOID: Hanging signal listener callbacks with unbounded `task.wait()` loops without spawning.
DO_NOT_ASSUME: Event callbacks execute in a specific guaranteed sequence order when multiple listeners exist.
RELATED_KNOWLEDGE: patterns/event-driven, patterns/cleanup, roblox/runservice
