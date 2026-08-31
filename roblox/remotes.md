TITLE: Roblox Remote Communication
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Remote instances facilitate network communication across the Client-Server boundary in Roblox. Understanding the operational differences between `RemoteEvent`, `RemoteFunction`, and `UnreliableRemoteEvent` is vital for security, latency management, and rate-limit compliance.

REMOTE_TYPES:
- `RemoteEvent`: Asynchronous, reliable one-way communication (non-yielding).
- `RemoteFunction`: Synchronous request/response communication (yields thread until response returned).
- `UnreliableRemoteEvent`: Asynchronous, unreliable one-way communication (messages may be dropped or unordered for ultra-low latency and lower bandwidth overhead).

DIRECTIONS & METHODS:
- Client -> Server: `RemoteEvent:FireServer(...)` -> `RemoteEvent.OnServerEvent:Connect(function(player, ...))`
- Server -> Client: `RemoteEvent:FireClient(player, ...)` -> `RemoteEvent.OnClientEvent:Connect(function(...)`
- Server -> All Clients: `RemoteEvent:FireAllClients(...)`
- Client -> Server Request: `RemoteFunction:InvokeServer(...)` -> `RemoteFunction.OnServerInvoke = function(player, ...)`

WHEN_TO_USE:
- Client requesting server actions (purchases, attacks) or Server notifying client of state changes.

WHEN_NOT_TO_USE:
- Do not use remotes for internal client-only or server-only module communications (use ModuleScripts or custom Signals).

CORE_RULES:
- Never trust client inputs. Always validate argument types, player ownership, and cooldowns on the Server.
- Avoid calling `RemoteFunction:InvokeClient()` from the Server (if client hangs/exploits, server thread yields indefinitely).
- Do not pass metatables, functions, or cyclic tables through remotes; pass primitives, vector/CFrame types, or Instance references.
- Throttle high-frequency remote calls (Roblox limits client remote throughput to ~500 calls/sec).

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `RemoteEvent`, `RemoteFunction`, `UnreliableRemoteEvent`, `FireServer`, `FireClient`, `FireAllClients`, `InvokeServer`, `OnServerEvent`, `OnClientEvent`, `OnServerInvoke`.
  CONTEXT_DEPENDENT: First argument of `OnServerEvent` / `OnServerInvoke` is ALWAYS automatically populated by the engine with the calling `Player` instance.
  DO_NOT_ASSUME: Clients cannot send parameter values that spoof the calling `Player` identity (the server engine enforces this).

ANTI_PATTERNS:

BAD:
```lua
-- Server Script
local data = RemoteFunction:InvokeClient(player, "GetData") -- CRITICAL SECURITY & STABILITY RISK!
```
WHY_BAD: If a malicious client blocks `OnClientInvoke`, the server thread freezes indefinitely, locking server memory.
BETTER: Use `RemoteEvent` for Server -> Client requests and receive replies via a separate `RemoteEvent:FireServer()`.

BAD:
```lua
-- Client Script
RunService.Heartbeat:Connect(function()
    RemoteEvent:FireServer(position) -- BAD: Reliable remote fired 60 times per sec!
end)
```
WHY_BAD: Exhausts network bandwidth and triggers engine rate limiting (~500 calls/sec limit).
BETTER: Use `UnreliableRemoteEvent` or throttle reliable remotes to 5-10 Hz.

PERFORMANCE:
`UnreliableRemoteEvent` drastically reduces network packet overhead for high-frequency position sync.

SECURITY_AND_TRUST_BOUNDARY:
All client-to-server remotes must treat incoming parameters as untrusted data. Validate types, numbers, and sanity bounds on the server.

LIFECYCLE_AND_CLEANUP:
Disconnect `OnClientEvent` connections when unloading client UI modules.

RELATED:
roblox/services
roblox/players
patterns/event-driven
patterns/error-handling

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Secure client-server requests.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Local UI updates.

```lua
-- Server Script
local BuyItemRemote = ReplicatedStorage:WaitForChild("BuyItem")

BuyItemRemote.OnServerEvent:Connect(function(player: Player, itemId: string)
    if type(itemId) ~= "string" then return end
    if validatePurchase(player, itemId) then
        processPurchase(player, itemId)
    end
end)
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Designing network architecture between Client LocalScripts and Server Scripts.
- Auditing scripts for client-side spoofing vulnerabilities or network thread locks.
THAI_KEYWORDS: รีโมท, เครือข่าย, สื่อสาร, ส่งข้อมูล, เซิร์ฟเวอร์, ไคลเอนต์, RemoteEvent, RemoteFunction
PREFER: `RemoteEvent` for 95% of client-server communications.
AVOID: `RemoteFunction:InvokeClient()` from Server to Client.
DO_NOT_ASSUME: First parameter of `OnServerEvent` can be set by the client (Server automatically injects `Player`).
RELATED_KNOWLEDGE: roblox/services, roblox/players, patterns/event-driven, patterns/error-handling
