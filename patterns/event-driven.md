TITLE: Event-Driven Architecture Pattern
CATEGORY: patterns
PRIORITY: S
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Event-driven architecture reacts to push notifications/events fired by the engine or other scripts, rather than continuously polling state inside loops (`while task.wait() do`). This drastically reduces CPU utilization, lowers latency, and produces clean code.

PREFER_EVENTS_FOR:
- Player lifecycle (`PlayerAdded`, `PlayerRemoving`).
- Character spawning (`CharacterAdded`, `CharacterRemoving`).
- Instance property/attribute updates (`GetPropertyChangedSignal`, `AttributeChanged`).
- User input handling (`InputBegan`, `InputEnded`).
- Network remotes (`OnClientEvent`, `OnServerEvent`).

PREFER_POLLING_FOR:
- Conditions where no native Roblox event exists.
- Distance checks between moving physical entities (when throttled to 2-5 Hz).

WHEN_TO_USE:
- Reacting to property changes, player joins, UI clicks, or network events.

WHEN_NOT_TO_USE:
- Continuous continuous physical position updates where no signal exists (use throttled loop).

CORE_RULES:
- Always prefer listening to native engine signals over running polling loops.
- Throttle unavoidable polling loops using interval timing (`task.wait(0.5)`).
- Track all event connections to ensure clean disconnection when features toggle off.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `GetPropertyChangedSignal`, `AttributeChanged`, `ChildAdded`, `ChildRemoved`, `PlayerAdded`, `CharacterAdded`.
  CONTEXT_DEPENDENT: Property changes caused by physics simulation do NOT fire `GetPropertyChangedSignal` (use `PostSimulation` for physics updates).
  DO_NOT_ASSUME: Event listeners consume CPU when idle (they consume 0 CPU when no event fires).

ANTI_PATTERNS:

BAD:
```lua
while task.wait(0.1) do
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.Health <= 0 then print("Died") end
    end
end
```
WHY_BAD: Executed 10 times/sec indefinitely, wasting CPU even when the player is idle or unchanged.
BETTER:
```lua
local function onChar(char)
    char:WaitForChild("Humanoid").Died:Connect(function() print("Died") end)
end
if LocalPlayer.Character then onChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onChar)
```

PERFORMANCE:
Event listeners consume 0 CPU cycles when idle. Polling loops consume active thread execution time every single cycle.

SECURITY_AND_TRUST_BOUNDARY:
Isolate callback logic using `task.spawn` to prevent one failing listener from blocking other event handlers.

LIFECYCLE_AND_CLEANUP:
Disconnect event listeners when features toggle off or target instances are destroyed.

RELATED:
roblox/players
roblox/runservice
patterns/cleanup
patterns/state-machine

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Reacting to state changes, player actions, network messages.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Un-signaled continuous distance math.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Designing responsive automation features, UI controllers, or network handlers.
- Deciding between `while task.wait() do` loops and Roblox signals.
THAI_KEYWORDS: เหตุการณ์, ตัวรับสัญญาณ, ทำงานเมื่อ, ปรับเปลี่ยน, อีเวนต์, event, signal, callback, Connect, Fire
PREFER: `GetPropertyChangedSignal("Name")` over checking properties inside frame loops.
AVOID: Unthrottled `while true do task.wait() end` loops for state checking.
DO_NOT_ASSUME: Property changes caused by physics fire `GetPropertyChangedSignal`.
RELATED_KNOWLEDGE: roblox/players, roblox/runservice, patterns/cleanup
