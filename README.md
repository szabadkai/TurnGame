# TurnGame - D&D-Inspired Turn-Based RPG

A sophisticated turn-based RPG built in GameMaker Studio 2, featuring D&D 5e-inspired mechanics, tactical combat, and a rich character progression system.

## 🎮 Live Demo

**[View the Game on GitHub Pages](https://szabadkai.github.io/TurnGame/)**

Experience the game through our interactive documentation site featuring:
- Complete promo gallery
- Game flow walkthrough
- Interactive dialog system demo
- Comprehensive game design documentation

## ✨ Key Features

### 🎲 D&D 5e-Inspired Character System
- **Six Ability Scores**: STR, DEX, CON, INT, WIS, CHA with D&D 5e modifier calculations
- **Leveling System**: XP-based progression with ability score improvements every 4 levels
- **Proficiency Bonus**: Scales with level following D&D 5e progression (2-6)
- **Combat Statistics**: Attack bonus, damage, and AC calculated from abilities + proficiency + equipment

### ⚔️ Advanced Combat System
- **Turn-Based Combat**: Sophisticated turn manager with shuffled initiative order
- **14 Unique Weapons**: Each with special abilities including:
  - Finesse weapons using DEX for attack/damage
  - Chain lightning effects
  - Area-of-effect attacks
  - Status effects (freeze, burn, reflection)
  - Counter-attacks and self-harm mechanics
- **Tactical Positioning**: Grid-based movement and strategic combat

### 🎭 Multiple Character System
- **7 Character Sprites**: Support for chr1 through chr7 with full animations
- **IDE-Configurable**: Set character appearance directly in GameMaker IDE
- **Complete Animation Sets**: Idle, run, and attack animations for all 4 directions
- **Automatic Fallback**: Missing sprites gracefully fall back to default sets

### 📊 Advanced UI System
- **Interactive Combat Log**: 3-state collapsible system (Full → One-line → Nub)
- **Character Sheet**: Detailed ability score display with combat statistics
- **Level-Up Interface**: Ability Score Improvement system for character progression
- **Real-time Feedback**: Color-coded messages and scrollable message history

### 🏗️ Robust Architecture
- **Object-Oriented Design**: Clean inheritance hierarchy with `character_base` parent class
- **Modular Scripts**: Reusable systems for XP, weapons, sprites, and utilities
- **Event-Driven System**: GameMaker's native event system for responsive gameplay
- **Scalable Structure**: Easy to extend with new characters, weapons, and abilities

## 🚀 Getting Started

### Prerequisites
- GameMaker Studio 2 (version 2024.13 or later)
- Windows, macOS, or Linux development environment

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/szabadkai/TurnGame.git
   cd TurnGame
   ```

2. **Open in GameMaker Studio 2**:
   - Launch GameMaker Studio 2
   - Open the project file: `Turnproject.yyp/Turnproject.yyp`

3. **Run the game**:
   - Press `F5` to launch Room1 (main game room)
   - Or use the Run button in the IDE toolbar

## 🎮 Controls & Gameplay

### Movement & Combat
- **Arrow Keys**: Move player character
- **Space Bar**: Attack enemies in range
- **Number Keys (1-9)**: Switch between available weapons

### Interface Controls
- **'I' Key**: Toggle character sheet/ability score display
- **'I' Key (when ASI available)**: Open Level-Up interface for ability improvements

### Combat Log Controls
- **'L' Key**: Cycle through log states (Full → One-line → Nub → Full)
- **Mouse Wheel**: Scroll through message history (when hovering over log)
- **Arrow Keys (Up/Down)**: Alternative scrolling method
- **Click Interactions**: Use collapse button and clickable nub for navigation

## 📁 Project Structure

```
TurnGame/
├── Turnproject.yyp/           # Main GameMaker project directory
│   ├── objects/               # Game objects (Player, Enemies, UI, etc.)
│   ├── scripts/               # Reusable GML functions and systems
│   ├── sprites/               # Character animations and visual assets
│   ├── rooms/                 # Game scenes/levels
│   └── fonts/                 # Text rendering assets
├── docs/                      # GitHub Pages documentation
│   ├── index.html            # Interactive game showcase
│   ├── promo/                # Promotional screenshots
│   ├── demogame/             # Gameplay flow screenshots
│   └── dialogs_scenes/       # Interactive dialog system
├── CLAUDE.md                 # Development guidelines and architecture
└── README.md                 # This file
```

## 🛠️ Development

### Core Systems

#### Turn Management (`obj_TurnManager`)
Central coordinator that maintains shuffled turn order for all `character_base` instances.

#### Character System (`character_base`)
Base class providing shared combat properties, ability scores, and D&D 5e calculations.

#### Weapon System (`weapon_system.gml`)
Comprehensive weapon definitions with special attack implementations and damage calculations.

#### Experience System (`xp_system.gml`)
Complete leveling system with ability score improvements and party XP distribution.

#### Character Sprites (`character_sprites.gml`)
Dynamic sprite system supporting multiple character appearances with fallback mechanisms.

### Testing & Debugging
- **Manual Testing**: Use `test_level_system.md` for comprehensive mechanics testing
- **Debug Console**: Combat log provides real-time action feedback
- **Quick Leveling**: Adjusted XP values for faster testing (enemies give 40-85 XP)
- **Level Up Testing**: Reach levels 4, 8, 12, 16, or 20 to trigger ASI

### Adding Content

#### New Weapons
1. Add weapon definition to `weapon_system.gml` in `init_weapons()` function
2. Increment array index and add `create_weapon()` call with special_type
3. Implement special attack logic in combat resolution functions

#### New Characters
1. Set `character_index` (1-7) in object properties via GameMaker IDE
2. Ensure sprites follow naming pattern: `chr[index]_[action]_[direction]`
3. System automatically handles fallback for missing sprites

## 📖 Documentation

- **[Live GitHub Pages Site](https://szabadkai.github.io/TurnGame/)**: Interactive showcase with gameplay demos
- **[CLAUDE.md](CLAUDE.md)**: Comprehensive development documentation
- **[Game Design Document](docs/Space%20Exploration%20Game%20-%20Core%20Narrative%20%26%20Branching%20Quests.pdf)**: Detailed design specifications
- **[Test Documentation](test_level_system.md)**: Testing procedures for D&D mechanics

## 🎨 Assets & Media

### Character Animations
- **Multiple Character Sets**: chr1-chr7 with complete animation cycles
- **Directional Sprites**: Full 4-direction support (up, down, left, right)
- **Action States**: Idle, running, and attack animations for each character
- **Weapon-Specific**: Sword and pistol animation variants

### Visual Style
- Pixel art character sprites with smooth animations
- Clean, readable UI with color-coded feedback
- Tactical grid-based combat visualization

## 🤝 Contributing

Contributions are welcome! Please refer to the development guidelines in `CLAUDE.md` for:
- Code conventions and patterns
- Architecture principles
- Testing procedures
- Asset naming conventions

## 📊 Technical Specifications

- **Engine**: GameMaker Studio 2 (2024.13+)
- **Language**: GML (GameMaker Language)
- **Target Platforms**: Windows, macOS, Linux, HTML5
- **Architecture**: Event-driven object-oriented design
- **Resolution**: Optimized for 160x90 base resolution with scaling

## 🏆 Features Showcase

### Combat System Highlights
- **Real-time Turn Order**: Visual feedback for turn-based combat flow
- **Weapon Variety**: 14 distinct weapons with unique mechanics
- **Status Effects**: Freeze, burn, and other tactical elements
- **Critical Hits**: D&D-style critical hit system with enhanced damage

### Character Progression
- **Ability Score Improvements**: Strategic character building every 4 levels
- **Proficiency Scaling**: Automatic bonus increases following D&D 5e rules
- **Equipment Integration**: Weapons modify stats based on character abilities

### User Experience
- **Intuitive Controls**: Simple keyboard-based interface
- **Rich Feedback**: Comprehensive combat log with color-coded messages
- **Accessibility**: Multiple input methods and clear visual indicators

## 📜 License

This project is part of a GameMaker Studio 2 educational/development portfolio. Please refer to individual asset licenses and GameMaker Studio 2 licensing terms.

---

**[🌟 Experience TurnGame on GitHub Pages](https://szabadkai.github.io/TurnGame/)**

*A tactical RPG that brings D&D mechanics to life in GameMaker Studio 2*