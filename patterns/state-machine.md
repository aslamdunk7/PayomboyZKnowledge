TITLE: Finite State Machine (FSM) Pattern
CATEGORY: patterns
PRIORITY: S
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
A Finite State Machine structures complex systems into explicit, mutually exclusive states (`IDLE`, `FARMING`, `PAUSED`, `ERROR`) with strictly controlled state transitions and lifecycle handlers (`onEnter`, `onExit`).

WHEN_TO_USE:
- A feature or bot has multiple distinct operational modes.
- Feature logic requires clean pause, resume, reset, or error recovery capabilities.
- Scattered boolean flags (`isFarming`, `isAttacking`, `isPaused`, `isDead`) become chaotic or race-prone.

WHEN_NOT_TO_USE:
- Simple single-action scripts without distinct states or modes.

CORE_RULES:
- Always centralize state transition logic; never modify state directly without firing transition handlers.
- Clean up temporary connections, loops, and visual indicators in the `onExit` handler of each state.
- Ensure state transitions are guarded against illegal transitions (e.g. `DEAD` -> `ATTACKING`).

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: States, Transitions, `onEnter`, `onExit`, Payload passing.
  CONTEXT_DEPENDENT: State transitions with asynchronous work must handle state cancellation if state changes mid-execution.
  DO_NOT_ASSUME: Multiple states can be active at the same time in a pure FSM.

ANTI_PATTERNS:

BAD:
```lua
local isFarming = false
local isAttacking = false
local isPaused = false
local isDead = false
```
WHY_BAD: Independent booleans desynchronize easily, causing invalid states (such as attacking while dead or farming while paused).
BETTER: Use an explicit State Machine where `CurrentState` can only equal one state at a time.

```lua
local FSM = { CurrentState = "IDLE", States = {} }

function FSM.SetState(newState, payload)
    if FSM.CurrentState == newState then return end
    local old = FSM.CurrentState
    if FSM.States[old] and FSM.States[old].onExit then pcall(FSM.States[old].onExit) end
    FSM.CurrentState = newState
    if FSM.States[newState] and FSM.States[newState].onEnter then pcall(FSM.States[newState].onEnter, payload) end
end
```

PERFORMANCE:
Eliminates redundant conditional checks across background threads, focusing CPU work strictly on active state logic.

SECURITY_AND_TRUST_BOUNDARY:
Validates state transitions to prevent exploits from triggering out-of-order execution states.

LIFECYCLE_AND_CLEANUP:
Execute state `onExit` handler whenever leaving a state.

RELATED:
patterns/cleanup
patterns/event-driven
roblox/players
patterns/error-handling

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Bot automation engines, UI tab workflows, combat bots.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Linear one-shot scripts.

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Designing automation engines, combat loops, or UI tab managers.
- Replacing buggy boolean flag conditions with deterministic state management.
THAI_KEYWORDS: สถานะ, โหมด, เปลี่ยนโหมด, ทำงาน, หยุด, สเตท, FSM, StateMachine
PREFER: Centralized `SetState(newState)` calls with `onEnter`/`onExit` hooks.
AVOID: Scattered boolean flags for mutually exclusive features.
DO_NOT_ASSUME: Background loops automatically stop on state change without checking `CurrentState`.
RELATED_KNOWLEDGE: patterns/cleanup, patterns/event-driven, patterns/error-handling
