TITLE: Roblox Services
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs (Official API Reference)
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Roblox services provide built-in engine functionality and system-level managers. Services act as singletons within the Roblox environment and are accessed using `game:GetService("ServiceName")`.

CORE_CONCEPTS:
- Engine Singletons: Only one instance of each service exists per game session.
- Context Isolation: Services operate on Client-only, Server-only, or Shared (Client & Server) boundaries.
- Initialization Guarantee: `game:GetService()` instantiates and returns the service if it is not yet initialized.

WHEN_TO_USE:
- Accessing engine subsystems (Players, Workspace, RunService, TweenService, Network).
- Setting up modular services or utility frameworks.

WHEN_NOT_TO_USE:
- Do not attempt to instantiate services manually using `Instance.new("Players")` or `Instance.new("Workspace")`.
- Do not access services via direct property dot notation (`game.Players` or `game.Workspace`) in production code.

CORE_RULES:
- Always use `game:GetService("ServiceName")` for service access.
- Cache service references at top-level script/module scope.
- Never call `game:GetService()` repeatedly inside high-frequency loops (e.g. 60 FPS `Heartbeat` or `RenderStepped`).
- Check context execution limits before using server-only or client-only services.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `Players`, `Workspace`, `RunService`, `ReplicatedStorage`, `UserInputService`, `TweenService`, `HttpService`, `CollectionService`, `Lighting`, `SoundService`, `ContextActionService`, `TeleportService`.
  CONTEXT_DEPENDENT: `HttpService` HTTP methods (Server-only), `UserInputService` (Client-only), `ServerStorage` (Server-only).
  DO_NOT_ASSUME: Client scripts cannot access `ServerStorage` or `ServerScriptService`. `HttpService` HTTP requests fail on the client.

SERVICES_SUMMARY:

Players:
  Purpose: Manages connected Player objects, character spawns, and player lookups.
  Context: Shared (Client & Server)
  Key APIs: `Players.LocalPlayer`, `Players.PlayerAdded`, `Players.PlayerRemoving`, `Players:GetPlayers()`

RunService:
  Purpose: Frame lifecycle timing, frame steps, and runtime environment checks.
  Context: Shared (Client & Server)
  Key APIs: `RunService.Heartbeat`, `RunService.PreRender`, `RunService.PostSimulation`, `RunService:IsClient()`, `RunService:IsServer()`

ReplicatedStorage:
  Purpose: Network-replicated container for shared ModuleScripts, RemoteEvents, and assets.
  Context: Shared (Client & Server)

Workspace:
  Purpose: 3D physical world containing physical parts, models, terrain, and active characters.
  Context: Shared (Client & Server)

UserInputService:
  Purpose: Captures keyboard, mouse, gamepad, and touch inputs on local device.
  Context: Client-only

TweenService:
  Purpose: Smooth property interpolation over time.
  Context: Shared (Client & Server)

HttpService:
  Purpose: JSON encoding/decoding, GUID generation, external HTTP web requests.
  Context: Server-only for HTTP methods; Shared for JSON operations.

ANTI_PATTERNS:

BAD:
```lua
while task.wait() do
    local plrs = game.Players:GetPlayers() -- BAD: Dot notation and un-cached lookup inside loop!
end
```
WHY_BAD: Dot notation breaks if the service is renamed or uninitialized; un-cached lookup wastes execution time inside high-frequency loops.
BETTER:
```lua
local Players = game:GetService("Players")
while task.wait() do
    local plrs = Players:GetPlayers()
end
```

PERFORMANCE:
GetService calls execute hash lookups in C++. Caching service references at module load scope reduces overhead to zero nanoseconds during loop execution.

SECURITY_AND_TRUST_BOUNDARY:
Markdown/Knowledge content is static decision data only. Never execute raw code strings dynamically.

LIFECYCLE_AND_CLEANUP:
Service references persist for the lifetime of the Lua state. No cleanup required for top-level service variables.

RELATED:
roblox/instances
roblox/players
roblox/runservice
roblox/remotes

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Initializing any Roblox script header.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Non-Roblox standalone Luau environments.

```lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Initializing a script header.
- Deciding which engine manager to use for player, world, or network tasks.
THAI_KEYWORDS: บริการ, เซิร์ฟเวอร์, ผู้เล่น, โลก, ทำงาน, ระบบ
PREFER: `game:GetService("ServiceName")` assigned to top-level local variables.
AVOID: Dot notation indexing like `game.ReplicatedStorage` or `game.Players`.
DO_NOT_ASSUME: Server-only services are accessible on the client.
RELATED_KNOWLEDGE: roblox/instances, roblox/players, roblox/runservice
