# Asset Manifest — Elemental Kineticist

Spec only — no binary assets produced yet.

## Viewport & Tiles

- Internal resolution: 320×240, integer-scaled (canvas_items stretch)
- Tile size: 16×16px
- Overworld grid: 20 tiles wide × 15 tiles tall visible at once

## Sprite Sheets

| Asset | Frame size | Notes |
|---|---|---|
| Player overworld | 16×16 | 4-directional walk cycle, 3 frames/direction |
| NPC overworld | 16×16 | Same layout as player for reuse |
| Battle sprite (player/enemy) | 32×32 | Front-facing, idle + attack + hit + faint |
| Tileset | 16×16 per tile | One sheet per zone biome |

## UI

- Dialogue box: 9-patch, corner size 8×8px, spans bottom third of 320×240 viewport
- Virtual D-Pad: 48×48px overlay, bottom-left safe zone
- Action button: 32×32px overlay, bottom-right safe zone
- Move-select panel (battle): 4×4 grid slots at 24×24px per icon, covers 6-move deck + 2 reserved

## Audio Cue Map (naming convention)

- `sfx_move_<discipline>_<moveid>.ogg` — e.g. `sfx_move_pyre_01.ogg`
- `sfx_status_<condition>.ogg` — stun / burn / freeze / root
- `sfx_ui_<action>.ogg` — confirm / cancel / cursor
- `music_zone_<zonename>.ogg`
- `music_battle_<tier>.ogg` — tier scales with ScalingEngine output (e.g. `low`, `mid`, `high`, `boss`)
