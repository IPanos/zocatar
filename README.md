# Zocatar

A retro 16-bit mobile 2D RPG inspired by GBA-style Pokémon games, built in Godot 4 using GDScript.

## Core Features

- **Top-down Overworld**: Tilemap movement, dialogue system with choice branches, and combat transitions
- **Turn-Based Combat**: 1v1 / 3v3 elemental kineticist duels with Chi/Energy meter and status conditions
- **Origin-Based Scaling**: Choose from 4 elemental origins (Aether/Air, Tide/Water, Terra/Earth, Pyre/Fire) with dynamic zone scaling
- **Persistent Save System**: JSON-serializable saves tracking origins, seals, move decks, and world state

## Technical Stack

- **Engine**: Godot 4
- **Language**: GDScript
- **Target**: Mobile (320x240 internal resolution, scaled for modern displays)
- **Save Format**: JSON

## Project Structure

```
zocatar/
├── scenes/           # Scene files (.tscn)
│   ├── overworld/
│   ├── battle/
│   └── ui/
├── scripts/          # GDScript files
│   ├── autoload/     # Global singletons
│   ├── systems/      # Core game systems
│   └── entities/     # Entities (player, enemies, NPCs)
├── assets/           # Game assets
│   ├── graphics/
│   ├── audio/
│   └── data/         # JSON data files
└── project.godot     # Godot project file
```

## Getting Started

1. Open this directory in Godot 4
2. The project will auto-initialize
3. Start with `scenes/overworld/overworld.tscn`

## License

MIT License - see LICENSE file for details
