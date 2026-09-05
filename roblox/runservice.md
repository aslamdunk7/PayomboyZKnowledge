TITLE: Roblox RunService
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
RunService provides runtime timing, frame lifecycle events, and execution context checks (`IsClient`, `IsServer`, `IsStudio`). Selecting the appropriate frame event is essential for rendering smoothness, physics synchronization, and CPU optimization.

CONTEXT_APIS:
- `IsClient()`: Returns `true` if executing on client.
- `IsServer()`: Returns `true` if executing on server.
- `IsStudio()`: Returns `true` if executing in Roblox Studio.
- `IsRunning()`: Returns `true` if game simulation is active.

FRAME_EVENTS:
- `PreRender` (Client-only): Fires before frame rendering. Use for camera adjustments and visual rendering.
- `PreAnimation`: Fires before skeletal animations evaluate.
- `PreSimulation`: Fires before physics simulation step. Use for applying physical forces/velocities.
- `PostSimulation`: Fires after physics simulation completes. Use for reading updated physics positions.
- `Heartbeat`: Fires at end of frame after physics. Use for general gameplay updates and periodic checks.

WHEN_TO_USE:
- Smooth camera hooks (`PreRender`), custom character physics (`PreSimulation`), or throttled periodic background tasks (`Heartbeat`).

WHEN_NOT_TO_USE:
- Do not use frame events when slow timers or event listeners suffice (e.g. use `GetPropertyChangedSignal` instead of checking health every frame).

CORE_RULES:
- Match event to task: camera -> `PreRender`, physics -> `PreSimulation`, gameplay -> `Heartbeat`.
- Never perform heavy operations (string search, deep scans, HTTP) every frame without throttling.
- Always disconnect `RBXScriptConnection` returned by RunService events when deactivating features.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `PreRender`, `PreAnimation`, `PreSimulation`, `PostSimulation`, `Heartbeat`, `IsClient`, `IsServer`, `IsStudio`.
  CONTEXT_DEPENDENT: `PreRender` is Client-only (errors if connected on Server!).
  DO_NOT_ASSUME: `Heartbeat` runs at fixed 60 FPS (frame delta time varies based on lag and device capabilities).

ANTI_PATTERNS:

BAD:
```lua
RunService.Heartbeat:Connect(function()
    local items = workspace:GetDescendants() -- BAD: 60 FPS heavy scanning!
end)
```
WHY_BAD: Scans thousands of descendants 60 times per second, starving CPU and causing frame drops.
BETTER: Use an accumulator to throttle execution to 2 Hz.

```lua
local accumulator = 0
local INTERVAL = 0.5

RunService.Heartbeat:Connect(function(deltaTime)
    accumulator += deltaTime
    if accumulator >= INTERVAL then
        accumulator -= INTERVAL
        -- Perform throttled scan safely here
    end
end)
```

PERFORMANCE:
`PreRender` yields the main rendering pipeline; keeping handlers lightweight is mandatory for 60+ FPS performance.

SECURITY_AND_TRUST_BOUNDARY:
Frame event connections are local thread logic. Ensure callbacks do not leak memory references.

LIFECYCLE_AND_CLEANUP:
Store connection handles and call `:Disconnect()` when feature is toggled off.

RELATED:
patterns/cleanup
patterns/cache
patterns/event-driven

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Smooth camera movement or throttled periodic state updates.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Static event handling (button clicks, player joins).

```lua
local connection = RunService.PreRender:Connect(function(deltaTime)
    camera.CFrame = camera.CFrame:Lerp(targetCFrame, deltaTime * 10)
end)
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Writing movement scripts, camera hooks, physics modifiers, or background loops.
- Throttling high-frequency frame tasks.
THAI_KEYWORDS: เฟรม, เวลา, หน่วง, ค้าง, แลค, ลูป, ทำงานทุกเฟรม, กล้อง
PREFER: Throttled `Heartbeat` loops over raw unthrottled frame loops for non-visual tasks.
AVOID: Heavy string operations or instance creation inside raw frame events.
DO_NOT_ASSUME: `PreRender` can be used on the Server.
RELATED_KNOWLEDGE: roblox/services, patterns/cleanup, patterns/event-driven

TITLE: Roblox Data Types
CATEGORY: roblox
PRIORITY: A
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Roblox engine data types (`Vector3`, `CFrame`, `Color3`, `UDim2`, `TweenInfo`, `RaycastParams`, `Enum`) represent spatial vectors, 3D transformations, colors, UI dimensions, and collision parameters.

DATATYPE MATRIX:

Vector3:
  Constructors: `Vector3.new(x, y, z)`, `Vector3.zero`, `Vector3.one`
  Key Methods: `.Magnitude` (distance), `.Unit` (direction), `:Dot()`, `:Cross()`

CFrame (Coordinate Frame):
  Constructors: `CFrame.new(x, y, z)`, `CFrame.lookAt(eye, target)`, `CFrame.Angles(rx, ry, rz)`
  Key Methods: `cf * CFrame.new(0,0,-5)` (relative forward translation), `:Inverse()`, `:Lerp(target, alpha)`

Color3:
  Constructors: `Color3.fromRGB(r, g, b)` [0..255], `Color3.new(r, g, b)` [0..1], `Color3.fromHSV(h, s, v)`

UDim2:
  Constructors: `UDim2.new(scaleX, offsetX, scaleY, offsetY)`, `UDim2.fromScale(sx, sy)`, `UDim2.fromOffset(ox, oy)`

TweenInfo:
  Constructor: `TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses, delayTime)`

RaycastParams:
  Constructor: `RaycastParams.new()` -> `.FilterDescendantsInstances`, `.FilterType`, `.IgnoreWater`

WHEN_TO_USE:
- Position, rotation, UI sizing, color styling, raycasting, and property animations.

WHEN_NOT_TO_USE:
- Do not use manual math equations when engine vector methods like `.Magnitude` or `:Lerp()` exist.

CORE_RULES:
- Use `CFrame.lookAt(eye, target)` instead of deprecated `CFrame.new(eye, target)`.
- Use `Color3.fromRGB(r, g, b)` [0..255] for visual clarity.
- Use `UDim2.fromScale()` or `UDim2.fromOffset()` shorthand constructors for single-dimension UI definitions.
- CFrame multiplication (`cfA * cfB`) is non-commutative; order of multiplication matters!

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `Vector3`, `CFrame`, `Color3`, `UDim2`, `UDim`, `TweenInfo`, `RaycastParams`, `OverlapParams`, `Enum`.
  CONTEXT_DEPENDENT: `RaycastParams.FilterType` uses `Enum.RaycastFilterType.Exclude` (or `Include`).
  DO_NOT_ASSUME: `cfA * cfB` equals `cfB * cfA` (matrix multiplication is order-sensitive!).

ANTI_PATTERNS:

BAD:
