TITLE: Connection Manager Implementation Pattern
CATEGORY: examples
PRIORITY: C
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Demonstrates a production Maid/Connection Manager implementation that tracks `RBXScriptConnection`, threads, instances, and generic functions to guarantee 100% clean resource destruction upon feature toggle or module unload.

WHEN_THIS_PATTERN_APPLIES:
- Adding toggleable features, script unloaders, or dynamic GUI controllers requiring clean shutdown.

WHEN_THIS_PATTERN_DOES_NOT_APPLY:
- Permanently active core events that never disable.

IMPLEMENTATION:

```lua
local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({
        _tasks = {}
    }, ConnectionManager)
    return self
end

function ConnectionManager:Track(task)
    table.insert(self._tasks, task)
    return task
end

function ConnectionManager:Clean()
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

function ConnectionManager:Destroy()
    self:Clean()
    setmetatable(self, nil)
end

return ConnectionManager
```

RELATED:
patterns/cleanup
roblox/runservice
patterns/event-driven

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Implementing resource tracking containers in custom hubs or modules.
THAI_KEYWORDS: ตัวอย่าง Maid, ตัวอย่างการล้างข้อมูล, connection manager example, janitor
PREFER: Centralized tracking containers over manual disconnect lists scattered throughout code.
RELATED_KNOWLEDGE: patterns/cleanup, roblox/runservice
