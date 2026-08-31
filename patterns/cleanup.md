TITLE: Connection Lifecycle and Cleanup Pattern
CATEGORY: patterns
PRIORITY: S
SOURCE: Internal Pattern (Verified Production Standard)
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Long-lived event connections (`RBXScriptConnection`), spawned tasks, dynamic UI objects, and temporary instances must have a deterministic lifecycle. Failing to clean up resources when modules unload, characters respawn, or features toggle off leads to memory leaks and duplicate execution bugs.

RESOURCE_TYPES TO TRACK & CLEAN:
- `RBXScriptConnection` (e.g. `event:Connect()`)
- `thread` handles (e.g. `task.spawn`, `task.delay`)
- Dynamic Roblox Instances (UI frames, temporary parts, visual effects)
- Custom callback functions

WHEN_TO_USE:
- Any toggleable feature, background automation loop, character script, or unloadable module.

WHEN_NOT_TO_USE:
- Script-lifetime singletons that run permanently until the place unloads and never toggle off.

CORE_RULES:
- Every connection, task, or dynamic instance created by a feature must have an explicit owner or maid container.
- Every toggleable feature must support complete, clean deactivation via a `Destroy` or `Clean` routine.
- Cleanup functions must be idempotent (safe to call multiple times without throwing errors).
- Distinguish between script-lifetime resources and character-lifetime resources (destroy on character death).

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `RBXScriptConnection:Disconnect()`, `Instance:Destroy()`, `task.cancel(thread)`, `table.clear(tbl)`.
  CONTEXT_DEPENDENT: Destroying a parent Instance automatically disconnects its descendants' signals, but NOT external signals referencing descendants.
  DO_NOT_ASSUME: Setting a variable or parent to `nil` disconnects RBXScriptConnections attached to that object.

MAID_PATTERN_IMPLEMENTATION:
```lua
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:GiveTask(task)
    table.insert(self._tasks, task)
    return task
end

function Maid:DoCleaning()
    for i = #self._tasks, 1, -1 do
        local task = self._tasks[i]
        self._tasks[i] = nil
        if typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif type(task) == "function" then
            pcall(task)
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif type(task) == "table" and type(task.Destroy) == "function" then
            pcall(function() task:Destroy() end)
        end
    end
end
```

ANTI_PATTERNS:

BAD:
```lua
local function enableFeature()
    RunService.RenderStepped:Connect(function() end) -- BAD: Anonymous connection!
end
```
WHY_BAD: Calling `enableFeature()` 5 times connects 5 duplicate listeners running simultaneously, multiplying CPU overhead.
BETTER:
```lua
local connection = nil
local function toggleFeature(enable)
    if connection then connection:Disconnect(); connection = nil end
    if enable then connection = RunService.RenderStepped:Connect(function() end) end
end
```

PERFORMANCE:
Dangling connections prevent Garbage Collection from freeing memory, leading to progressive lag over long sessions. Clean disconnects free memory instantly.

SECURITY_AND_TRUST_BOUNDARY:
Clean unbind ensures disabled features cannot execute unauthorized background actions.

LIFECYCLE_AND_CLEANUP:
Execute `DoCleaning()` on feature disable, character removing, or script unloading.

RELATED:
roblox/runservice
roblox/players
patterns/event-driven
patterns/state-machine

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Toggleable UI, automation features, character modules.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Permanently active core event handlers.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Implementing toggleable hub options, character scripts, or UI views.
- Preventing memory leaks and duplicate event executions.
THAI_KEYWORDS: ล้าง, ทำความสะอาด, ปิดการทำงาน, คืนหน่วยความจำ, ลบ, cleanup, clear, disconnect, destroy, Maid
PREFER: Centralized `Maid` container for managing multiple connections.
AVOID: Anonymous `:Connect()` calls inside functions executed repeatedly.
DO_NOT_ASSUME: Disabling a UI Frame automatically disconnects inner button signals.
RELATED_KNOWLEDGE: roblox/runservice, roblox/players, patterns/state-machine
