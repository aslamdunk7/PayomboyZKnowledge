TITLE: Player Cache Implementation Pattern
CATEGORY: examples
PRIORITY: C
SOURCE: Internal Pattern
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Demonstrates a production-ready, leak-free Player Cache module combining `Players` lifecycle events (`PlayerAdded`, `PlayerRemoving`, `CharacterAdded`), event-driven cache invalidation, and explicit connection cleanup.

WHEN_THIS_PATTERN_APPLIES:
- Tracking player stats, team states, or local character root references safely across player joins, deaths, and leaves.

WHEN_THIS_PATTERN_DOES_NOT_APPLY:
- Static world objects or non-player NPCs.

IMPLEMENTATION:

```lua
local Players = game:GetService("Players")

local PlayerCache = {
    _cache = {},
    _connections = {}
}

local function setupCharacter(player: Player, character: Model)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not hrp or not humanoid then return end

    if PlayerCache._cache[player] then
        PlayerCache._cache[player].Character = character
        PlayerCache._cache[player].Root = hrp
        PlayerCache._cache[player].Humanoid = humanoid
    end
end

local function onPlayerAdded(player: Player)
    PlayerCache._cache[player] = {
        Player = player,
        Name = player.Name,
        Character = nil,
        Root = nil,
        Humanoid = nil,
        JoinedAt = os.time()
    }

    local conn = player.CharacterAdded:Connect(function(character)
        setupCharacter(player, character)
    end)
    PlayerCache._connections[player] = conn

    if player.Character then
        setupCharacter(player, player.Character)
    end
end

local function onPlayerRemoving(player: Player)
    if PlayerCache._connections[player] then
        PlayerCache._connections[player]:Disconnect()
        PlayerCache._connections[player] = nil
    end
    PlayerCache._cache[player] = nil
end

function PlayerCache.Init()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(onPlayerAdded, player)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function PlayerCache.Get(player: Player)
    return PlayerCache._cache[player]
end

return PlayerCache
```

WHY_THIS_WORKS:
1. Listens to `PlayerAdded` and `PlayerRemoving` to manage lifecycle.
2. Iterates existing `Players:GetPlayers()` on start so players who joined before module load are captured.
3. Automatically disconnects `CharacterAdded` connections when the player leaves.

RELATED:
roblox/players
patterns/cache
patterns/cleanup
patterns/event-driven

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Implementing player tracking, stat caching, or targeting systems.
THAI_KEYWORDS: ตัวอย่างแคชผู้เล่น, โค้ดแคชผู้เล่น, ตัวอย่างการจัดการผู้เล่น, player cache example
PREFER: Utilizing this pattern as architectural guidance for player lifecycle management.
DO_NOT_ASSUME: Copying this code verbatim is required for simple single-variable checks.
RELATED_KNOWLEDGE: roblox/players, patterns/cache, patterns/cleanup
