# Art Generation Brief — PLACEHOLDER DOCUMENT

**Status: this file exists only until real artwork replaces the procedural placeholder
tiles in `assets/graphics/`. Delete it once every asset below has a finished replacement
checked in.** It is not game documentation — it's a spec for whoever (human artist or
image-generation tool) produces the real art.

---

## 1. Master style-anchor prompt

Prepend or append this to every specific asset prompt below, to keep every generated
image visually consistent:

> 16-bit pixel art, GBA-era JRPG style (Pokémon FireRed / Golden Sun aesthetic), inspired
> by traditional East Asian decorative motifs and mythology — cloud-scroll (雲紋),
> wave (水波紋), key-fret/meander (回紋), mountain silhouette (山紋), and flame-swirl
> (火紋) patterns; ink-wash-influenced shading with clean pixel edges, no anti-aliasing,
> no gradients, limited flat color palette (max ~12 colors per sprite), transparent
> background, crisp 1px outlines, orthographic top-down or front-facing as specified per
> asset, no text or watermarks in the image.

**Do not** reference or imitate any specific existing copyrighted game, film, or
illustrated character — the brief above points at generic pattern *categories* and a
generic retro-JRPG *style*, not a specific copyrighted work to copy.

## 2. Global technical constraints

- Internal viewport: 320×240, integer-scaled
- Tile size: 16×16px
- Format: PNG, RGBA (transparent background except where noted)
- No compression artifacts — export lossless
- Pixel-perfect: no anti-aliasing, no sub-pixel blending: nearest-neighbor-safe
- Palette-locked per asset (list exact hex values used, so recolors/variants stay consistent)

## 3. Per-origin palette + motif reference

These carry forward the procedural placeholders already in the tileset — real art
should stay recognizably in this direction, not invent new palettes:

| Origin | Motif | Base floor color | Accent color |
|---|---|---|---|
| Aether (Air) | Cloud-scroll (雲紋) | `#B4DCEB` light sky blue | `#FFFFFF` white |
| Tide (Water) | Wave arcs, seigaiha-style (水波紋) | `#3C6EAA` deep blue | `#194573` darker blue |
| Terra (Earth) | Layered mountain silhouette (山紋) | `#966E46` brown | `#644628` dark brown |
| Pyre (Fire) | Flame swirl (火紋) | `#C85A3C` warm red-orange | `#FFC850` yellow |

Shared/neutral tiles: wall uses key-fret (回紋) at `#464648` on `#46464B`; water/void uses
a denser wave pattern at `#0A162A` on `#14284A`; obstacle (boulder/crate) uses a rough
cross-hatch at `#3C3223` on `#5A503C`.

## 4. Asset checklist

Every filename below is the exact path the code/data already expects — a drop-in
replacement needs no code changes if the finished file lands at that path.

### 4.1 Tilesets — `assets/graphics/tileset_overworld.png`

Single 112×16px strip, 7 tiles left-to-right, each 16×16: wall, floor-Aether,
floor-Tide, floor-Terra, floor-Pyre, water/void, obstacle. See palette table above.
Prompt per tile: "top-down 16×16 game tile, [motif from table], [base color], seamless
tileable pattern" + style-anchor prompt.

*(Longer-term: each origin's zone probably wants its own richer tileset — floor
variants, decoration tiles, water edges, etc. — rather than one shared 7-tile strip.
That's a bigger scope than this brief covers; flag it separately when ready.)*

### 4.2 Player character sprite — `assets/graphics/player.png` (not yet created)

- 16×16 frame size, 4-directional walk cycle (up/down/left/right), 3 frames per
  direction = 12 frames total
- Should support a palette-swap or recolor per chosen origin (Aether/Tide/Terra/Pyre)
  rather than 4 fully separate sprite sheets, if feasible
- Prompt: "16×16 top-down RPG character walk cycle, 3-frame animation per direction,
  androgynous young protagonist in simple travel clothing, [origin accent color] trim" +
  style-anchor prompt

### 4.3 NPC sprites — `assets/graphics/npcs/<name>.png` (not yet created)

Same 16×16 / 3-frames-per-direction spec as the player, one file per named NPC:

| Filename | Character | Notes |
|---|---|---|
| `elder_corin.png` | Elder Corin | Aether Nomad elder — monk robes, aged |
| `chief_kanaak.png` | Chief Kanaak | Tide Clan chief — fur-trimmed coat |
| `master_goran.png` | Master Goran | Terra Dominion arena master — heavy build |
| `general_ignis.png` | General Ignis | Pyre Empire general — militaristic armor |
| `master_rai.png` | Master Rai | Lightning discipline — storm-worn robes |
| `swamp_hermit.png` | Swamp Hermit | Flora discipline — moss/vine-covered |
| `desert_nomad.png` | Desert Nomad | Vapor discipline — desert wraps |
| `inventor_kyle.png` | Inventor Kyle | Metal discipline — goggles, tool belt |
| `lady_morgana.png` | Lady Morgana | Vitalis/Blood discipline — dark, moonlit |
| `novice_monk.png` | Novice Monk | generic Aether monastery NPC |
| `engineer.png` | Engineer | generic Pyre Empire NPC |
| `pyre_scout.png` | Pyre Scout | generic Pyre Empire patrol NPC |

### 4.4 Battle sprites — `assets/graphics/battle/<name>.png` (not yet created)

- 32×32 frame size, front-facing (player) or side-facing (enemy), states: idle, attack,
  hit, faint (4 frames minimum per combatant)
- One per player origin (`player_aether.png`, `player_tide.png`, `player_terra.png`,
  `player_pyre.png`) and one per named boss:

| Filename | Character |
|---|---|
| `mountain_sovereign.png` | The Mountain Sovereign (Terra final boss vs. Aether start) |
| `ember_warlord.png` | The Ember Warlord (Pyre final boss vs. Tide start) |
| `hurricane_warlord.png` | The Hurricane Warlord (Aether final boss vs. Terra start) |
| `tsunami_matriarch.png` | The Tsunami Matriarch (Tide final boss vs. Pyre start) |

### 4.5 Dialogue portraits — `assets/graphics/portraits/<portrait_id>.png` (not yet created)

Every `portrait_id` referenced by `data/dialogue/*.json` today — filename must match
exactly for a drop-in replacement:

`corin_neutral`, `kanaak_neutral`, `goran_neutral`, `ignis_neutral`, `rai_neutral`,
`hermit_neutral`, `nomad_neutral`, `kyle_neutral`, `morgana_neutral`,
`novice_monk_neutral`, `engineer_neutral`, `pyre_scout_neutral`,
`hurricane_warlord_neutral`, `tsunami_matriarch_neutral`, `player_neutral`

- Suggested size: 48×48 or 64×64 (bigger than overworld sprites — dialogue portraits
  are usually closer-up)
- One "neutral" expression each for now; additional expressions (happy/angry/etc.) are
  a future `<name>_<expression>.png` naming extension, not needed yet

### 4.6 UI assets — `assets/graphics/ui/` (not yet created)

| Filename | Spec |
|---|---|
| `dialogue_box.png` | 9-patch, 8×8px corners, spans bottom third of 320×240 |
| `dpad.png` | 48×48 virtual D-pad overlay |
| `action_button.png` | 32×32 action button overlay |
| `hp_bar_frame.png` | frame/border for the HP ProgressBar |
| `chi_bar_frame.png` | frame/border for the Chi/Energy ProgressBar |
| `status_stun.png`, `status_burn.png`, `status_freeze.png`, `status_root.png` | 16×16 status condition icons |

### 4.7 Move icons — `assets/graphics/moves/<move_id>.png` (not yet created)

24×24px icon per move, one file per existing `move_id` (see `data/moves/*.json` for
flavor text to inform the icon design):

`move_gale_slash`, `move_static_gust`, `move_tidal_press`, `move_frost_lock`,
`move_stone_fist`, `move_root_wall`, `move_ember_jab`, `move_cinder_wave`,
`move_arc_flash`, `move_lightning_redirect`, `move_vine_snare`, `move_vapor_form`,
`move_iron_siege`, `move_puppeteers_grasp`

## 5. Delivery checklist

- [ ] Every PNG is RGBA with a genuinely transparent background (not white/checkered)
- [ ] Every sprite sheet's frame size and frame count matches section 4 exactly
- [ ] Colors match the palette table (or a documented, deliberate deviation)
- [ ] Filenames match exactly (case-sensitive) so no code changes are needed
- [ ] No stray padding/whitespace around sprites — frames should tile/align exactly
      at their stated pixel size
