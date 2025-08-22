# ChatGPT Background Generation Style Guide for The Exodus Protocol

## Overview
This guide provides optimized prompting techniques for generating 320×180 pixel art backgrounds using ChatGPT/DALL-E (2025) that match The Exodus Protocol's established visual style. It incorporates findings from the existing capsule style guide and current game assets.

---

## Visual Style Analysis

### Current Game Background (Sprite-0001.gif)
**Core Characteristics:**
- **Resolution**: 320×180 pixel art with tactical grid overlay
- **Color Palette**: Purple/magenta ancient ruins with teal/cyan mystical accents
- **Architecture**: Stone archways, mystical eye symbols, layered depth
- **Composition**: Foreground tactical grid, midground ruins, background atmospheric depth
- **Lighting**: Ambient purple glow with cyan accent lighting on symbols

### Demogame Visual Consistency
**Established Elements:**
- **UI Integration**: Dark blue/teal interface panels with orange accent buttons
- **Atmospheric Lighting**: Dramatic contrast with glowing energy effects
- **16-bit Aesthetic**: Detailed but retro, reminiscent of classic tactical RPGs
- **Character Integration**: Clean sprite work with strong silhouettes
- **Environmental Depth**: Multiple background layers creating atmospheric perspective

### Capsule Guide Integration
**Key Principles to Maintain:**
- Warm/cool color contrasts for visual drama
- Strong silhouettes and clear visual hierarchy
- Dramatic lighting with bloom effects
- Cinematic composition and framing
- Balance between minimal character detail and rich environments

---

## 2025 ChatGPT/DALL-E Best Practices

### GPT-4o Capabilities
- **Enhanced Detail Handling**: Can manage 10-20 distinct objects vs 5-8 in older models
- **Improved Style Consistency**: Better adherence to specific art style requests
- **Rendering Time**: Up to 1 minute for detailed pixel art images
- **Prompt Following**: More precise interpretation of technical specifications

### Optimal Prompt Structure
```
[RESOLUTION SPEC] + [STYLE TYPE] + [SUBJECT/SCENE] + [COMPOSITION] + [COLOR PALETTE] + [LIGHTING] + [TECHNICAL DETAILS]
```

### Critical Technical Requirements
- **Resolution**: Always specify "320×180 resolution" or "low resolution pixel art"
- **Style Consistency**: Use "16-bit pixel art" rather than mixing with other styles
- **Scaling**: Mention "designed for integer scaling to modern displays"
- **Grid Integration**: Specify "tactical grid overlay" for combat backgrounds

### Common Pitfalls to Avoid
- Don't mix "pixel art" with "hyper-realistic" unless intentionally surreal
- Avoid vague descriptions like "retro game background"
- Don't omit resolution specifications
- Avoid overly complex scenes (stick to 10-15 key elements maximum)

---

## Background Template System

### Base Template Structure
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background for [LOCATION TYPE]. 

FOREGROUND: Grid-based battle arena made of [FLOOR MATERIAL] with [COVER ELEMENTS] providing tactical positioning.

BACKGROUND: [ENVIRONMENTAL SETTING] with [ATMOSPHERIC EFFECTS] creating depth and mood.

COLOR PALETTE: [PRIMARY COLORS] for [MOOD/THEME] atmosphere, with [ACCENT COLORS] for [LIGHTING/EFFECTS].

STYLE: Detailed 16-bit pixel art optimized for integer scaling, reminiscent of classic tactical RPGs like Heroes of Might and Magic 3, with clean sprite integration areas.
```

### Modular Components

#### Floor Materials
- `dark stone tiles with ancient engravings`
- `metallic deck plating with energy conduits`
- `organic resin floors with bio-mechanical patterns`
- `crystalline formations with harmonic resonance patterns`
- `fractured reality platforms with void energy cracks`

#### Cover Elements
- `mystical monoliths with glowing eye symbols`
- `twisted metal debris and sparking conduits`
- `crystalline spires and harmonic pillars`
- `organic pods and chitinous barriers`
- `reality distortion fields and energy pillars`

#### Environmental Settings
- `ancient alien ruins with soaring archways`
- `corrupted spaceship interior with hull breaches`
- `crystalline sanctuary with geometric architecture`
- `bio-mechanical hive chambers with organic tunnels`
- `dimensional gateway with fractured space effects`

#### Color Palettes
- `deep purples and magentas with cyan accents` (Alien Ruins)
- `dark blues and teals with orange warning lights` (Spaceship)
- `sapphire blues and crystal whites with geometric light patterns` (Keth'mori)
- `organic yellows and chitin browns with acid greens` (Swarm Hive)
- `void blacks and electric purples with reality-tear whites` (Void Space)

---

## Location-Specific Optimized Prompts

### 1. Ancient Keth'mori Ruins (Updated Alien Ruin Template)
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in a mysterious Keth'mori ruin under starlight. 

FOREGROUND: Grid-based battle arena made of polished obsidian tiles with geometric Keth'mori patterns, featuring towering crystalline formations and harmonic resonance crystals as tactical cover elements.

BACKGROUND: Soaring faceted archways and crystalline spires reaching toward a domed ceiling with transparent crystal panels showing constellations, ancient mystical eye symbols glowing with ethereal energy throughout the architecture.

COLOR PALETTE: Deep sapphire blues and crystal whites for sacred atmosphere, with geometric purple light patterns and ethereal cyan accents for harmonic energy effects.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with sacred alien architecture aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 2. Prometheus Derelict Interior
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in a corrupted spaceship under void energy storms.

FOREGROUND: Grid-based battle arena of twisted metallic deck plating with sparking energy conduits and bio-mechanical fusion growths serving as cover, creating natural barriers and environmental hazards.

BACKGROUND: Damaged bulkheads with void energy crackling through hull breaches, twisted corridors disappearing into darkness, swirling purple void energies visible through tears in reality.

COLOR PALETTE: Sickly greens and corrupted purples for eldritch atmosphere, with rust reds and warning amber lights creating technological horror mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with eldritch corruption aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 3. Swarm Hive Interior
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in an alien bio-mechanical hive under bioluminescent lighting.

FOREGROUND: Grid-based battle arena of organic resin floors with chitinous walls forming natural barriers, featuring pulsing bio-conduits and egg sacs creating dynamic cover elements.

BACKGROUND: Towering hive chambers with organic tunnels branching in all directions, massive Queen's chamber visible in the distance, bioluminescent nodes providing eerie illumination throughout the structure.

COLOR PALETTE: Organic yellows and chitin browns for hive atmosphere, with acidic greens and pulsing bioluminescent blues creating living architecture mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with living hive-mind aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 4. Void Gate Threshold
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background at an ancient dimensional gateway under cosmic storms.

FOREGROUND: Grid-based battle arena of dark stone tiles with reality distortion effects creating shifting terrain, featuring void energy pillars as unstable cover that phases in and out.

BACKGROUND: Massive ring-shaped portal crackling with dimensional energy, floating debris from multiple timelines, fractured space showing glimpses of other realities and impossible geometry.

COLOR PALETTE: Void blacks and electric purples for cosmic atmosphere, with reality-tear whites and temporal blues creating dimensional instability mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with cosmic horror aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 5. Planetary Surface (Beast Ambush)
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in a hostile alien jungle under twin moons.

FOREGROUND: Grid-based battle arena of cracked earth with alien vegetation providing cover, featuring twisted trees with bioluminescent bark and carnivorous plants creating natural hazards.

BACKGROUND: Dense jungle canopy with predatory eyes glowing in shadows, ancient ruins visible through undergrowth, two moons casting eerie silver light through the canopy creating atmospheric depth.

COLOR PALETTE: Deep jungle greens and moonlight silvers for nocturnal atmosphere, with predator amber and alien bioluminescent teals creating dangerous ecology mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with predatory alien atmosphere and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 6. Earth Command Center
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in a military command center under emergency lighting.

FOREGROUND: Grid-based battle arena of reinforced floor panels with holographic command tables and tactical displays, featuring security barriers and weapon racks providing strategic cover.

BACKGROUND: Massive viewscreens showing fleet deployments, Earth visible through reinforced windows, officers at command stations with warning lights flashing throughout the facility.

COLOR PALETTE: Military grays and tactical blues for professional atmosphere, with alert reds and Earth's natural colors creating crisis management mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with military precision aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

### 7. Fractured Space Region
```
Create a 320×180 resolution, 16-bit pixel art tactical combat background in broken reality under impossible geometry.

FOREGROUND: Grid-based battle arena of floating stone platforms with gravity-defying debris as cover, featuring space-time fractures creating portal-like hazards and dimensional barriers.

BACKGROUND: Reality shards showing fragments of different locations simultaneously, impossible angles and recursive architecture, starfields twisted into geometric patterns defying physics.

COLOR PALETTE: Paradox whites and dimension-break purples for reality strain atmosphere, with reality-strain blues and void-touched silvers creating temporal chaos mood.

STYLE: Detailed 16-bit pixel art optimized for integer scaling with mind-bending geometry aesthetic and clean sprite integration areas, reminiscent of classic tactical RPGs.
```

---

## Quality Assurance Guidelines

### Essential Checklist
- [ ] 320×180 resolution explicitly specified
- [ ] 16-bit pixel art style mentioned
- [ ] Tactical grid integration included
- [ ] Color palette matches established game aesthetic
- [ ] Sprite integration areas considered
- [ ] Integer scaling optimization mentioned
- [ ] Environmental depth and atmosphere present
- [ ] Cover elements strategically placed for gameplay

### Iteration Process
1. **Generate Initial**: Use base template with location-specific modifications
2. **Evaluate Consistency**: Compare against Sprite-0001.gif and demogame images
3. **Refine Prompts**: Adjust color descriptions and architectural details
4. **Test Integration**: Ensure backgrounds work with existing UI and character sprites
5. **Document Variations**: Save successful prompt variations for reuse

### Success Metrics
- Visual consistency with established game assets
- Proper 320×180 resolution and scaling
- Clear tactical positioning areas
- Appropriate mood and atmosphere for narrative context
- Clean integration with existing UI elements

---

## Technical Notes

### Resolution Specifications
- **Base Resolution**: 320×180 (16:9 aspect ratio)
- **Perfect Scaling**: 2x = 640×360, 3x = 960×540, 6x = 1920×1080
- **Display Optimization**: Use nearest neighbor interpolation for scaling
- **Asset Integration**: Ensure backgrounds accommodate 32×32 pixel character sprites

### ChatGPT Usage Tips
- Always specify resolution in the first line of prompts
- Use descriptive but not overly complex language
- Include "16-bit pixel art" rather than generic "pixel art"
- Mention "tactical RPG" for style consistency
- Be specific about color palettes using established game colors

### File Management
- Generate at 320×180 for direct game use
- Save high-quality versions for potential upscaling
- Use consistent naming: `bg_[location]_[variant].png`
- Maintain prompt logs for successful generations

---

*This guide should be updated as new ChatGPT/DALL-E capabilities become available and as The Exodus Protocol's visual style evolves.*