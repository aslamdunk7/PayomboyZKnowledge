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
```lua
local dist = math.sqrt((p1.X - p2.X)^2 + (p1.Y - p2.Y)^2 + (p1.Z - p2.Z)^2) -- BAD: Manual math!
```
WHY_BAD: Re-implementing Euclidean distance manually in Luau is slower than engine SIMD operations.
BETTER:
```lua
local dist = (p1 - p2).Magnitude -- BETTER: Fast C++ engine vector magnitude
```

PERFORMANCE:
Vector and CFrame operations run directly in C++ hardware instructions; leverage `.Magnitude`, `.Unit`, and `:Lerp()` for maximum performance.

SECURITY_AND_TRUST_BOUNDARY:
Datatypes are value primitives. Safe to pass across internal module calls and remotes.

LIFECYCLE_AND_CLEANUP:
Primitive value types are garbage collected automatically when references drop.

RELATED:
roblox/services
roblox/instances

EXAMPLE:
WHEN_THIS_PATTERN_APPLIES: Spatial position, teleportation, UI layout, raycasting.
WHEN_THIS_PATTERN_DOES_NOT_APPLY: Non-spatial data.

```lua
local spawnCF = CFrame.lookAt(Vector3.new(0, 10, 0), Vector3.new(100, 10, 0))
character:PivotTo(spawnCF)
```

AI_GUIDANCE:
USE_THIS_KNOWLEDGE_WHEN:
- Writing 3D calculations, teleports, camera offsets, UI layouts, or raycasts.
THAI_KEYWORDS: ไดเมนชัน, พิกัด, เวกเตอร์, ตำแหน่ง, สี, ขนาด, วาป, CFrame, Vector3
PREFER: `(posA - posB).Magnitude` for distance checks.
AVOID: Deprecated `CFrame.new(pos, lookAt)` syntax.
DO_NOT_ASSUME: `cfA * cfB == cfB * cfA`.
RELATED_KNOWLEDGE: roblox/instances, roblox/services
