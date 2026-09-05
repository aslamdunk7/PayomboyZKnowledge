TITLE: Roblox Players
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
The `Players` service manages connected `Player` objects and player lifecycle. Distinguishing between the long-lived `Player` object lifetime and the short-lived `Character` object lifetime (which resets upon death/respawn) is critical.

PLAYER_LIFECYCLE:

Server Lifecycle:
  PlayerAdded -> Player object created -> CharacterAdded -> Character model created -> CharacterRemoving -> Character destroyed -> PlayerRemoving

Client Lifecycle:
  Players.LocalPlayer available -> CharacterAdded -> CharacterRemoving

WHEN_TO_USE:
- Tracking connected players, character spawns, respawns, health, inventory, or combat targets.

WHEN_NOT_TO_USE:
- Do not use player character references for static persistent world state that should exist independent of player presence.

CORE_RULES:
- Never access `Players.LocalPlayer` in server scripts (evaluates to `nil`).
- Never assume `player.Character` or `character:FindFirstChild("HumanoidRootPart")` exists immediately without checking.
- Clean up connections attached to a player's character when `CharacterRemoving` fires or when respawning.
- Iterate existing `Players:GetPlayers()` before connecting `PlayerAdded` on the server.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `Players.LocalPlayer`, `Players.PlayerAdded`, `Players.PlayerRemoving`, `Players:GetPlayers()`, `Players:GetPlayerFromCharacter()`, `player.Character`, `player.CharacterAdded`, `player.CharacterRemoving`.
  CONTEXT_DEPENDENT: `LocalPlayer` exists ONLY on Client. `Character` is `nil` during load or respawn delay.
  DO_NOT_ASSUME: `PlayerAdded` fires for players who joined BEFORE the server script initialized (must iterate `GetPlayers()`).

ANTI_PATTERNS:

BAD:
```lua
-- Server Script
local player = Players.LocalPlayer -- BAD: LocalPlayer is nil on server!
```
WHY_BAD: `LocalPlayer` is only populated in client environment contexts.
BETTER: Use `OnServerEvent` player argument or iterate `Players:GetPlayers()`.

BAD:
```lua
Players.PlayerAdded:Connect(function(player)
    local hrp = player.Character.HumanoidRootPart -- BAD: Character is nil when PlayerAdded fires!
end)
```
WHY_BAD: Character model spawns asynchronously AFTER the Player instance is created.
BETTER: Listen to `player.CharacterAdded` and use `WaitForChild("HumanoidRootPart")`.

PERFORMANCE:
Cache player references and HumanoidRootPart references during character lifetime rather than calling `workspace:FindFirstChild(player.Name)` every frame.

SECURITY_AND_TRUST_BOUNDARY:
Server scripts must validate player ownership and distance before executing actions requested by clients.

LIFECYCLE_AND_CLEANUP:
Disconnect character-bound event listeners on `CharacterRemoving` to prevent dangling listener leaks.

RELATED:
roblox/services
roblox/instances
patterns/cleanup
patterns/cache
patterns/state-machine

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Safe player tracking on Server or Client.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Non-player NPC handling.

```lua
local Players = game:GetService("Players")

local function setupPlayer(player: Player)
    local function setupCharacter(character: Model)
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if hrp and humanoid then
            -- Character initialized safely
        end
    end

    if player.Character then setupCharacter(player.Character) end
    player.CharacterAdded:Connect(setupCharacter)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, player)
end
Players.PlayerAdded:Connect(setupPlayer)
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Writing player tracking, inventory management, or combat automation.
- Handling respawn events and character initialization.
THAI_KEYWORDS: ผู้เล่น, ตัวละคร, สปอว์น, เกิด, ตาย, ผู้ใช้, ไอเทม
PREFER: Listening to `player.CharacterAdded` over polling `player.Character`.
AVOID: Referencing `Players.LocalPlayer` in server code.
DO_NOT_ASSUME: `player.Character` exists instantly when `PlayerAdded` fires.
RELATED_KNOWLEDGE: roblox/services, patterns/cleanup, patterns/cache

TITLE: Roblox Players
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
The `Players` service manages connected `Player` objects and player lifecycle. Distinguishing between the long-lived `Player` object lifetime and the short-lived `Character` object lifetime (which resets upon death/respawn) is critical.

PLAYER_LIFECYCLE:

Server Lifecycle:
  PlayerAdded -> Player object created -> CharacterAdded -> Character model created -> CharacterRemoving -> Character destroyed -> PlayerRemoving

Client Lifecycle:
  Players.LocalPlayer available -> CharacterAdded -> CharacterRemoving

WHEN_TO_USE:
- Tracking connected players, character spawns, respawns, health, inventory, or combat targets.

WHEN_NOT_TO_USE:
- Do not use player character references for static persistent world state that should exist independent of player presence.

CORE_RULES:
- Never access `Players.LocalPlayer` in server scripts (evaluates to `nil`).
- Never assume `player.Character` or `character:FindFirstChild("HumanoidRootPart")` exists immediately without checking.
- Clean up connections attached to a player's character when `CharacterRemoving` fires or when respawning.
- Iterate existing `Players:GetPlayers()` before connecting `PlayerAdded` on the server.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `Players.LocalPlayer`, `Players.PlayerAdded`, `Players.PlayerRemoving`, `Players:GetPlayers()`, `Players:GetPlayerFromCharacter()`, `player.Character`, `player.CharacterAdded`, `player.CharacterRemoving`.
  CONTEXT_DEPENDENT: `LocalPlayer` exists ONLY on Client. `Character` is `nil` during load or respawn delay.
  DO_NOT_ASSUME: `PlayerAdded` fires for players who joined BEFORE the server script initialized (must iterate `GetPlayers()`).

ANTI_PATTERNS:

BAD:
