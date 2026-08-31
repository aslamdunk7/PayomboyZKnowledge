TITLE: Finite State Machine Implementation Pattern
CATEGORY: examples
PRIORITY: C
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Demonstrates a production Finite State Machine implementation for managing feature modes, bot automation states, and combat loops cleanly.

WHEN_THIS_PATTERN_APPLIES:
- Designing state-based bot routines, combat modes, or UI tab flows.

WHEN_THIS_PATTERN_DOES_NOT_APPLY:
- Basic linear scripts.

IMPLEMENTATION:

```lua
local StateMachine = {
    CurrentState = "IDLE",
    _states = {}
}

function StateMachine.RegisterState(name: string, config: { onEnter: ((any) -> ())?, onExit: (() -> ())? })
    StateMachine._states[name] = config
end

function StateMachine.SetState(newState: string, payload: any?)
    if StateMachine.CurrentState == newState then return end
    if not StateMachine._states[newState] then
        warn("[FSM] Invalid state requested:", newState)
        return
    end

    local oldState = StateMachine.CurrentState
    if StateMachine._states[oldState] and StateMachine._states[oldState].onExit then
        pcall(StateMachine._states[oldState].onExit)
    end

    StateMachine.CurrentState = newState

    if StateMachine._states[newState] and StateMachine._states[newState].onEnter then
        pcall(StateMachine._states[newState].onEnter, payload)
    end
end

-- Example Registration:
StateMachine.RegisterState("IDLE", {
    onEnter = function() print("[FSM] Entered IDLE state") end,
    onExit = function() print("[FSM] Exited IDLE state") end
})

StateMachine.RegisterState("FARMING", {
    onEnter = function() print("[FSM] Started FARMING loop") end,
    onExit = function() print("[FSM] Stopped FARMING loop") end
})

return StateMachine
```

RELATED:
patterns/state-machine
patterns/cleanup
patterns/event-driven

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Implementing state machines for bots or UI state controllers.
THAI_KEYWORDS: ตัวอย่างสเตทแมชชีน, state machine example, FSM example
PREFER: Centralized `SetState` transitions with guarded `onEnter`/`onExit` handlers.
RELATED_KNOWLEDGE: patterns/state-machine, patterns/cleanup
