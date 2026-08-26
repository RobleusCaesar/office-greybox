# THE WINDOW

Playable Godot **4.7** first-person loop for founder playtest (**Rob Carpenter**). Web build only — GitHub Pages.

Luxury office. Denver is on fire. Nolan dread, not comedy. Greybox + architecture materials.

Main scene: `res://scenes/title.tscn` → Play loads the office.

---

## Controls

| Input | Action |
|---|---|
| **W A S D** | Move |
| **Mouse** | Look |
| **LMB / click** | Fire (click also captures the mouse) |
| **R** | Reload |
| **1 / 2** or **scroll** | Shotgun / pistol |
| **Space** | Jump |
| **Esc** | Release mouse (title screen too) |

---

## Walk path (spawn → money shot)

L-shaped circulation. **No line of sight** from spawn, the north hall, or the east hall to the money-shot window. Reception back wall blocks it. Enter the CEO office from the **side**, then turn east.

1. Spawn in the **break room**, facing north.
2. Short **north hall**. West: **bathroom** (~8.5 × 6.4 m, door ~1.2 m). East: locked supply closet.
3. Blind corner, turn **east**.
4. **East hall.** South: cubicle choke (`DemonSpot_01`, first demon). North: copy alcove. Further south: **locked glass conference** (~5.0 × 4.25 m).
5. **Reception.** Walk around the solid wall behind the desk.
6. **CEO office** via the south or north side opening. `DemonSpot_02` at the south threshold (second demon).
7. Turn **east**. Three panes: stylized **Denver on fire**, demon silhouettes in the smoke. Brightest thing in the level. One-time light/audio sting the first time you face it.
8. Stand at the glass for a beat: soft win card. Menu or keep walking.

Death: **You died** / Retry / Menu.

---

## Combat

- **Shotgun** (primary): pellet spread, kick, short range, chunky.
- **Pistol** (weapon 2): single hitscan, longer range.
- Two killable demons. They telegraph before they hit. You can die.

---

## Materials (architecture only — furniture stays untextured cubes)

| Surface | Read |
|---|---|
| Floors | Dark polished stone |
| Walls | Warm plaster |
| Ceilings | Light |
| Doors | Dark wood |
| Mullions | Dark metal |
| Money-shot panes | Albedo + emission `textures/denver_fire_pane_0*.png` |

Compatibility renderer. No SDFGI. Glow enabled if the web export keeps it.

---

## Web / Pages

`.github/workflows/pages.yml` on push to `main`:

- Exact binary `Godot_v4.7.2-stable_linux.x86_64` (underscore before `linux`)
- Never `chmod` an empty path
- Web export with **threads off**
- Require `export/web/index.html` **and** `index.wasm`
- `deploy-pages`
