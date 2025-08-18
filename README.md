# TurnGame

A turn-based RPG built in GameMaker Studio 2 with D&D 5e-inspired mechanics.

**[🎮 View on GitHub Pages](https://szabadkai.github.io/TurnGame/)**

## Features

- **D&D 5e Combat**: Six ability scores, leveling system, proficiency bonus
- **14 Unique Weapons**: Special abilities like chain lightning, freeze, burn effects
- **Multiple Characters**: 7 character sprites with full directional animations  
- **Turn-Based Combat**: Tactical grid-based battles with initiative order
- **Interactive UI**: Collapsible combat log, character sheets, level-up interface

## Getting Started

**Requirements**: GameMaker Studio 2 (2024.13+)

1. Clone the repository
2. Open `Turnproject.yyp/Turnproject.yyp` in GameMaker Studio 2
3. Press F5 to run

## Controls

- **Arrow Keys**: Move
- **Space**: Attack
- **Numbers 1-9**: Switch weapons
- **I**: Character sheet / Level up
- **L**: Toggle combat log

## Development

Built with GameMaker Language (GML) using object-oriented design. Key systems:

- `obj_TurnManager`: Turn-based combat coordinator
- `character_base`: Base class for all combat entities  
- `weapon_system.gml`: 14 unique weapons with special abilities
- `xp_system.gml`: D&D 5e leveling and ability score improvements

See `CLAUDE.md` for detailed development documentation.