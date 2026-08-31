TITLE: Roblox Instances
CATEGORY: roblox
PRIORITY: S
SOURCE: Roblox Creator Docs
VERSION: 2026-v1
LAST_REVIEWED: 2026-08-31
CONFIDENCE: HIGH (100%)

DESCRIPTION:
Instance is the base object class for all items in the Roblox DataModel hierarchy (Parts, Models, Folders, GUI elements). Understanding instance creation, parenting order, tree lookups, attributes, and destruction lifecycle is mandatory for memory safety.

CORE_CONCEPTS:
- Parent: Defines object location in the DataModel tree. Setting `Parent` allocates physics, rendering, and network replication resources.
- Child: Direct single-level child contained inside an Instance.
- Descendant: Any object nested below an Instance at any depth.

WHEN_TO_USE:
- Manipulating physical world objects, UI components, or hierarchical folder trees.
- Searching for specific items in Workspace or ReplicatedStorage.

WHEN_NOT_TO_USE:
- Do not use instances when pure Luau primitives or tables suffice (e.g. use a Luau table for state data instead of creating dozens of `StringValue` or `IntValue` instances).

CORE_RULES:
- Never assume an Instance exists on the client without checking or using `WaitForChild`.
- Set properties (Size, Color, CFrame, Name) BEFORE setting `Parent` when instantiating objects with `Instance.new()`.
- Avoid calling `GetDescendants()` repeatedly inside 60+ FPS loops.
- Always use `Destroy()` to delete instances and disconnect attached event listeners.

HALLUCINATION_RESISTANCE_MATRIX:
  KNOWN: `FindFirstChild`, `WaitForChild`, `GetChildren`, `GetDescendants`, `IsA`, `Destroy`, `GetAttribute`, `SetAttribute`, `GetAttributeChangedSignal`.
  CONTEXT_DEPENDENT: Replication delay between Server and Client means client instances may arrive asynchronously.
  DO_NOT_ASSUME: Setting `Parent = nil` does NOT destroy an instance or disconnect its script connections.

IMPORTANT_APIS:
- `FindFirstChild(name, recursive)`: Returns child matching `name` or `nil`.
- `WaitForChild(name, timeout)`: Yields until child exists or `timeout` expires.
- `GetChildren()`: Returns an array of direct children.
- `GetDescendants()`: Returns an array of all nested descendants.
- `IsA(className)`: Checks if object matches or inherits from `className`.
- `Destroy()`: Unparents instance, disconnects all signals, locks `Parent` to `nil`.
- `GetAttribute(name)` / `SetAttribute(name, val)`: Reads/writes custom metadata.

ANTI_PATTERNS:

BAD:
```lua
local part = Instance.new("Part", workspace) -- BAD: Parent passed in constructor!
part.Size = Vector3.new(4, 4, 4)
```
WHY_BAD: Triggers immediate physics and render registration before properties are set, wasting CPU/network replication bandwidth.
BETTER:
```lua
local part = Instance.new("Part")
part.Size = Vector3.new(4, 4, 4)
part.Parent = workspace -- BETTER: Parent set last
```

BAD:
```lua
RunService.Heartbeat:Connect(function()
    for _, item in ipairs(workspace.Folder:GetDescendants()) do end -- BAD: Heavy scanning every frame!
end)
```
WHY_BAD: `GetDescendants()` builds a new table every frame by recursing the entire subtree, creating huge garbage collection spikes.
BETTER: Cache direct children and listen to `ChildAdded`/`ChildRemoved`.

PERFORMANCE:
`IsA("ClassName")` is C++ optimized and significantly faster than `ClassName == "Name"`. `GetAttribute()` is faster and lighter than creating `ValueObject` instances.

SECURITY_AND_TRUST_BOUNDARY:
Never execute untrusted string scripts retrieved from instance properties or names.

LIFECYCLE_AND_CLEANUP:
Always call `instance:Destroy()` when removing temporary objects to prevent connection leaks.

RELATED:
roblox/services
roblox/players
patterns/cleanup
patterns/cache

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Dynamic object creation and hierarchy manipulation.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Static environment objects initialized at place load.

```lua
local part = Instance.new("Part")
part.Name = "DropItem"
part.Size = Vector3.new(2, 2, 2)
part.CFrame = spawnLocation
part:SetAttribute("ItemID", 104)
part.Parent = workspace
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Creating, destroying, or searching objects in Roblox hierarchy.
- Reading or writing properties and attributes.
THAI_KEYWORDS: อินสแตนซ์, วัตถุ, สร้าง, ลบ, ค้นหา, โฟลเดอร์, พาร์ท
PREFER: `instance:IsA("BasePart")` over `instance.ClassName`.
AVOID: `Instance.new("Class", parent)` constructor pattern.
DO_NOT_ASSUME: Setting `Parent = nil` destroys the instance.
RELATED_KNOWLEDGE: roblox/services, patterns/cleanup, patterns/cache
