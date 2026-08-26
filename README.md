# THE WINDOW

Godot **4.7** first-person loop for founder playtest (web / GitHub Pages).

Luxury office. Denver is on fire. Nolan dread. Title `res://scenes/title.tscn` is the main scene.

## Controls

| Input | Action |
|---|---|
| **W A S D** | Move |
| **Mouse** | Look |
| **LMB** | Fire (also captures mouse) |
| **R** | Reload |
| **E** | Take ammo (crate mesh disappears) |
| **Space** | Crouch (no jump) |
| **1 / 2** or scroll | Shotgun / pistol |
| **Esc** | Release mouse (title too) |

## Loop

L-shaped circulation. No line of sight from spawn, north hall, or east hall to the money-shot window. Reception back wall blocks it. Enter the CEO from the side, turn east.

- **Break room** — textured kitchen, TV looping PLEASE STAND BY / THIS IS NOT A TEST / DENVER METRO / analog snow.
- **Bathroom** — real men's room (stalls, toilets, urinals, sinks, mirror). MEN decal on the ajar door. WOMEN on the locked hall door. No second walkable bathroom.
- **East hall** — papers, fallen door, glass shards, blood, pulsing red emergency lights. One bipedal demon in the cubicle choke (`DemonSpot_01`). 3–5 shotgun shells. One ammo crate (E to take).
- **CEO** — quiet walnut desk (knee well, drawers) off the first window sightline. Liquor + warm glow left, plant/frame right, dark polished floor. Walls carry the room: painted plaster, baseboards, chair rails, scuffs, maps and certificates. Furniture recedes.
- **Window** — three **clear glass** panes. Unreachable `ExteriorDiorama` east of the glass: single `denver-fire-vista.png` backdrop, animated fire planes, CPU smoke particles, drifting people silhouettes.

Soft win after standing at the glass. Death: You died / Retry / Menu.

Compatibility renderer. Pages workflow on `main` uses exact `Godot_v4.7.2-stable_linux.x86_64`.
