# Game Design Document (GDD) - Void’s Edge

## 1. Game Overview
**Title:** Void’s Edge  
**Genre:** Tactical RPG / Narrative-driven Space Exploration  
**Style:** Pixel art, retro-inspired with modern UI overlays  
**Core Loop:** Explore → Encounter → Make Choices → Tactical Combat → Progress Story → Metaprogression  

The player commands a crew venturing into the frontier of space, uncovering the fate of the lost ship *Prometheus* and facing the encroaching Void. Each run takes about 30–45 minutes, with branching choices, tactical battles, and lasting consequences through metaprogression.

---

## 2. Core Gameplay

### 2.1 Exploration
- Node-based map structure (branching paths).  
- Each node is one of: **Event**, **Encounter**, **Combat**, **Fork**, **Climax**, **Wrap-Up**.  
- Runs are designed to be short but impactful (3 acts, ~6–8 nodes per act).  

### 2.2 Dialogue & Choices
- Dialogue boxes with skill checks (Intellect, Willpower, Diplomacy, Engineering, Athletics).  
- “Void Touched” special options unlock based on corruption level.  
- Consequence previews for some actions (+Fuel, +Intel, +Crew, +Morale).  

### 2.3 Tactical Combat
- Grid-based combat inspired by Heroes of Might & Magic and D&D rules.  
- Turn order determined by initiative rolls.  
- Actions include Move, Attack, Ability, Cover.  
- Dice rolls determine combat outcomes, shown on UI.  

### 2.4 Metaprogression
- Between runs, players unlock:  
  - **Lore Codex:** Permanent fragments revealing story of *Prometheus*.  
  - **Crew Traits:** Persistent buffs or flaws earned from past corruption.  
  - **Resources:** Fuel, Intel, Crew Survivors carried over in limited capacity.  

---

## 3. Narrative Structure

### Act 1: Into the Unknown
- Departure from Earth, first encounters with anomalies, pirates, and void corruption.  
- Ends with descent to alien ruins.  

### Act 2: Ruins of the Past
- Exploration of ancient ruins and colonist conflicts.  
- Encounters corruption directly.  
- Ends with confrontation against Crystal Guardian and escape.  

### Act 3: The Prometheus Truth
- Final approach to the Prometheus wreck.  
- Crew fractures, void entities manifest.  
- Endings: [Victory], [Assimilation], [Pact].  

---

## 4. Art & Visuals
- Pixel art, landscape orientation for scenes.  
- Space scenes: starfields, anomalies, derelicts, fleets.  
- Ruins & caverns: alien glyphs, crystals, corrupted fauna.  
- Combat UI: Grid overlays, dice pop-ups, initiative panel.  
- Debrief screens: retro terminal style with flicker effects.  

---

## 5. Audio & Atmosphere
- **Music:** Ambient synth, retro sci-fi with dark undertones.  
- **SFX:** Dice rolls, console beeps, blaster fire, void whispers.  
- **Tone:** Tense, mysterious, balancing exploration wonder and creeping dread.  

---

## 6. Target Audience & Platform
- **Audience:** Fans of narrative RPGs, tactical combat, roguelike runs.  
- **Platform:** PC (Steam, itch.io), potential for Switch port.  
- **Session Length:** 30–45 minutes per run, high replayability.  

---

## 7. Technical Notes
- Engine: Unity or Godot (2D grid combat support).  
- Save/Load for metaprogression only (roguelike runs reset otherwise).  
- Pixel art resolution: 1024x576 baseline (landscape).  

---

## 8. Unique Selling Points (USP)
- Narrative-driven roguelike where choices have persistent consequences.  
- Blends **D&D dice mechanics** with **Heroes of Might & Magic combat grid**.  
- Multiple endings with metaprogression unlocks tied to corruption paths.  
- Short, replayable runs with evolving lore discovery.  

---
