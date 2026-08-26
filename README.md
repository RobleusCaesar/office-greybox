# Office Greybox — GATE 1 (v2)

Founder walkthrough for **Rob Carpenter**. Primitive-volume office so you can inspect scale, circulation, and the last-corner reveal with WASD + mouse look.

Godot 4.x text project. Main scene: `res://scenes/level.tscn`. No packs, guns, enemies, textures, audio, or title screen.

1 Godot unit = 1 meter. Ceilings 3.0 m. Player eye height 1.7 m. Capsule 1.8 m tall × 0.64 m wide. Doors ~0.9 m × 2.1 m.

**Circulation lock:** there is no straight-shot hallway. The player cannot see `MoneyShotWindow` from spawn, the north hall, or the east hall. Shock-and-awe is the last-corner reveal — you walk around the reception back wall, enter the CEO office from the *side*, then turn east.

---

## Controls

| Input | Action |
|---|---|
| **W A S D** | Move (`move_forward` / `move_left` / `move_back` / `move_right`) |
| **Mouse** | Look |
| **Space** | Jump (`jump`) |
| **Click** | Capture mouse |
| **Esc** | Release mouse (`ui_cancel`) |

---

## Walk path (spawn → money shot)

1. **Spawn in the break room** (south-west). You face **north** toward the open doorway. Kitchenette (counter, cabinets, fridge, coffee pot, clutter boxes) along the south wall. Table + 4 chairs in the middle. **Vending machine** on the east wall. A **small dim window** on the west wall — not the money shot, not emissive ember.
2. Optional poke: walk the kitchenette and around the table. Then through the **open doorway** (1.0 × 2.1 m, frame only) into the **short north hall**.
3. **North hall.** West: open doorway into the **bathroom** (step in — 2 stall volumes + sink). East: **supply closet** — closed locked slab, cannot enter. You cannot see the CEO window from here.
4. Hall hits a **blind corner** and turns **east**.
5. **East hall** (longer). South alcove = **cubicle stub / DemonSpot_01** (first demon: tight choke you must pass). North: **copy/mail alcove** (copier + mail-slot boxes) — walk in. Further south: **dead-end office** with a locked door and a darker glass pane you cannot walk through.
6. Hall opens west-into-east into **reception**. Staging space, not the reveal. Reception desk with a **solid wall behind it** so you cannot see through to the CEO window. Waiting chairs, a plant, a badge niche. Openings on **both sides** of that wall (left and right) — walk around.
7. **CEO office** — entered from the **side** (south or north opening). **DemonSpot_02** sits at the south threshold (second demon: arena, after the corner, as the window hits). Then **turn east**.
8. **MoneyShotWindow** fills the frame: floor-to-ceiling, **three vertical panes** with mullions, emissive ember, brightest thing in the level. Desk centered in front of the window. Liquor cabinet + warm extra light on the **left** as you face the window. Plant on the right. Bookshelves off the window wall. Walk up to the glass. (Burning Denver comes later. No city / fire in this gate.)

---

## Room dimensions

| Space | Size (X × Z × height) | World bounds (m) |
|---|---|---|
| Break room | 7.0 × 6.5 × 3.0 | X 0–7, Z 0–6.5 |
| North hall (short) | 2.0 × 4.5 × 3.0 | X 2.5–4.5, Z 6.5–11.0 |
| Bathroom | 4.0 × 3.6 × 3.0 | X −1.5–2.5, Z 7.2–10.8 |
| Supply closet (closed) | 2.5 × 2.6 × 3.0 | X 4.5–7.0, Z 7.2–9.8 |
| Corner (blind east turn) | 2.0 × 2.0 × 3.0 | X 2.5–4.5, Z 11.0–13.0 |
| East hall | 13.5 × 2.0 × 3.0 | X 4.5–18.0, Z 11.0–13.0 |
| Cubicle stub (DemonSpot_01) | 3.5 × 3.2 × 3.0 | X 7.5–11.0, Z 7.8–11.0 |
| Copy / mail alcove | 4.5 × 3.5 × 3.0 | X 7.5–12.0, Z 13.0–16.5 |
| Dead-end office (locked) | 4.0 × 3.4 × 3.0 | X 13.2–17.2, Z 7.6–11.0 |
| Reception | 8.0 × 10.0 × 3.0 | X 18.0–26.0, Z 6.5–16.5 |
| CEO office | 12.0 × 10.0 × 3.0 | X 26.0–38.0, Z 6.5–16.5 |
| Open doorway (break → north hall) | 1.0 wide × 2.1 tall | X 3.0–4.0, Z = 6.5 |
| Bathroom door | 0.9 wide × 2.1 tall | X = 2.5, Z 8.55–9.45 |
| Supply closet door (locked) | 0.9 wide × 2.1 tall | X = 4.6, Z 8.05–8.95 |
| Side openings (reception → CEO) | ~2.0 wide × 3.0 tall | X = 26, Z 6.6–8.5 (south) and 14.5–16.4 (north) |
| Money-shot window | 5.4 wide × 2.90 tall, 3 panes, floor-to-ceiling | X = 38.1, Z 8.8–14.2, Y 0.05–2.95 |

**Spawn:** Player at `(3.50, 0.00, 2.10)`, facing +Z (north, toward the north-hall doorway). Eye at Y = 1.70.

**Line of sight:** There is **no** line-of-sight from spawn, the north hall, or the east hall into `MoneyShotWindow`. The reception back wall covers the window’s Z span. You only see the ember after you walk around that wall and turn east in the CEO office.

---

## Demon spots (no enemies in this gate)

Named nodes under `DemonSpots`. Dull-red unshaded floor decal + low marker. **Collision OFF** — walk through the marker.

| Node | Where | Encounter | Why the space works |
|---|---|---|---|
| `DemonSpot_01` | Cubicle stub, south of the east hall | **First** — attack + interest | Tight **choke**. You must pass it. Close range, no room to kite. |
| `DemonSpot_02` | CEO south threshold, beside the side opening | **Second** — attack + interest | Bigger room = **arena**. After the corner, just as you enter / as the window hits. Punishes the turn into the money shot. |

Each node has an `editor_description` stating first vs second and choke vs arena.

---

## Color key (flat, no image textures)

| Function | Material | RGB |
|---|---|---|
| Floors | `materials/mat_floor.tres` | 0.22, 0.24, 0.28 slate |
| Walls | `materials/mat_wall.tres` | 0.76, 0.73, 0.66 putty |
| Ceilings | `materials/mat_ceiling.tres` | 0.88, 0.87, 0.84 off-white |
| Kitchen | `materials/mat_kitchen.tres` | 0.62, 0.40, 0.20 amber wood |
| Furniture | `materials/mat_furniture.tres` | 0.25, 0.36, 0.44 steel blue |
| Locked door slabs | `materials/mat_locked_door.tres` | 0.12, 0.10, 0.09 charcoal |
| Door frames / mullions | `materials/mat_door_frame.tres` | 0.22, 0.16, 0.12 dark brown |
| Money-shot window | `materials/mat_window.tres` | 1.00, 0.42, 0.10 emissive ember |
| Dim glass (break window, dead-office pane) | `materials/mat_dim_glass.tres` | 0.16, 0.18, 0.22 dim, not ember |
| Demon markers | `materials/mat_demon.tres` | 0.55, 0.11, 0.10 dull red, unshaded |

---

## Architecture vs future-asset slots vs demon spots

Nodes under `Architecture` are **permanent greybox structure** (floors, walls, ceilings, openings). Do not replace these with props; they define the playable volume.

Nodes under `FutureAssetSlots` are **placeholders** to be swapped for real meshes later. Each has an `editor_description` in the scene.

Nodes under `DemonSpots` are **encounter block-outs** (no actual enemies). Collision off on the markers.

### Architecture (keep)

- Floors: `BreakRoomFloor`, `NorthHallFloor`, `BathroomFloor`, `SupplyClosetFloor`, `CornerFloor`, `EastHallFloor`, `CubicleFloor`, `CopyAlcoveFloor`, `DeadOfficeFloor`, `ReceptionFloor`, `CEOOfficeFloor`
- Matching ceilings (same names with `Ceiling`)
- Break room: `BreakRoomSouth`, `BreakRoomWest` (small window cut), `BreakRoomEast`, `BreakRoomNorth` (open doorway)
- North hall: `NorthHallWest` (bathroom door cut), `NorthHallEast` (supply door cut, plugged by locked slab)
- Bathroom: `BathroomSouth`, `BathroomWest`, `BathroomNorth`
- Supply: `SupplySouth`, `SupplyEast`, `SupplyNorth`
- Corner: `CornerWest`, `CornerNorth`
- East hall: `EastHallSouth` (cubicle opening + dead-office door/glass cuts), `EastHallNorth` (copy opening)
- Cubicle: `CubicleWest`, `CubicleSouth`, `CubicleEast`
- Copy alcove: `CopyWest`, `CopyNorth`, `CopyEast`
- Dead-end office: `DeadOfficeWest`, `DeadOfficeSouth`, `DeadOfficeEast`
- Reception: `ReceptionWest` (hall mouth), `ReceptionSouth`, `ReceptionNorth`
- `ReceptionCEODivider` — solid wall behind the desk; south + north walk-around openings
- CEO: `CEOSouth`, `CEONorth`, `CEOEast` (floor-to-ceiling window cut)
- Openings: `OpenDoorway_BreakToNorthHall`, `OpenDoorway_NorthHallToBathroom`, `OpenDoorway_EastHallToCubicle`, `OpenDoorway_EastHallToCopy`, `Opening_HallToReception`, `Opening_ReceptionToCEO_South`, `Opening_ReceptionToCEO_North`

### Future-asset slots (replace later)

**Break room**

- `KitchenetteCounter`, `KitchenetteCabinets`, `Fridge`, `CoffeePot`, `CounterClutter_01`, `CounterClutter_02`
- `VendingMachine`
- `BreakRoomTable`, `BreakRoomChair_01` … `BreakRoomChair_04`
- `BreakRoomWindow` — small dim pane; not the money shot

**Bathroom**

- `StallPartition`, `StallVolume_01`, `StallVolume_02`, `StallWall_South`, `StallWall_North`
- `Sink`, `SinkBacksplash`

**Supply closet** (not enterable)

- `LockedDoor_Supply` (`Frame` + `Slab`)
- `Shelf_01`, `ShelfBox_01`

**East hall**

- Cubicle: `CubiclePartition`, `CubicleDesk`, `CubicleChair`
- Copy: `Copier`, `MailSlotBank`, `MailSlot_01` … `MailSlot_03`, `CopyTable`
- Dead-end office: `LockedDoor_DeadOffice` (`Frame` + `Slab`), `DeadOfficeGlass`, `DeadOfficeDesk`, `DeadOfficeChair`

**Reception**

- `ReceptionDesk`, `ReceptionDeskTop`, `BadgeNiche`
- `WaitingChair_01` … `WaitingChair_03`
- `PlantPot`, `PlantFoliage`

**CEO office**

- `CEODesk`
- `LiquorCabinet`, `LiquorBottles` — left as you face the window
- `PlantPot`, `PlantFoliage` — right as you face the window
- `Bookshelf_01`, `Bookshelf_02`, `Bookshelf_03` — off the window wall
- `MoneyShotWindow` — `Pane_01` / `Pane_02` / `Pane_03` + mullions + sill + head. Placeholder emissive glass; future burning-Denver vista

### Demon spots

- `DemonSpot_01` / `DemonSpot_02` (each has `Decal` + `Marker`)

---

## Lights

Enough omni lights to read every room. `WindowLight` is the strongest source in the CEO office (and the level) so the money-shot plane is the brightest thing there. `LiquorCabinetLight` is a warm extra on the left as you face the window. Modest environment glow helps the ember read as emissive. The small break-room window stays dim.

---

## Files

```
project.godot
README.md
scenes/level.tscn
scenes/player.tscn
scripts/player.gd
materials/mat_floor.tres
materials/mat_wall.tres
materials/mat_ceiling.tres
materials/mat_kitchen.tres
materials/mat_furniture.tres
materials/mat_locked_door.tres
materials/mat_door_frame.tres
materials/mat_window.tres
materials/mat_dim_glass.tres
materials/mat_demon.tres
```

Open the folder in Godot 4 → Play (`F5`). Main scene is already set.

Windows export: `export/windows/OfficeGreybox.exe`  
Zip: `export/OfficeGreybox-windows.zip`
