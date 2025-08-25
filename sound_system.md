# Sound System Documentation

## Overview

The Turnproject uses a comprehensive, easily extendable audio system that handles both background music and sound effects with centralized management, volume control, and smooth transitions.

## System Architecture

### **Core Files:**
- **`scripts/menu_audio/menu_audio.gml`** - Main audio system implementation
- **`Room_MainMenu/RoomCreationCode.gml`** - Starts menu background music
- **`Room_StarMap/RoomCreationCode.gml`** - Starts starmap background music

### **Key Features:**
- **Centralized track database** - All audio assets defined in `global.audio_tracks`
- **Volume control system** - Separate master, music, and SFX volume settings
- **Automatic fade transitions** - Smooth background music changes between rooms
- **Type separation** - Background music vs sound effects with different volume controls
- **Resource validation** - Graceful fallback when GameMaker sound resources aren't imported
- **Real-time volume adjustment** - Changes apply immediately to currently playing tracks

## Current Implementation Status

### **✅ Available Sounds:**

#### **Background Music:**
- **`ObservingTheStar.ogg`** - Used for both menu and starmap background music

#### **Menu Sound Effects:**
- **`menu_beep.mp3`** - Navigation sound (arrow keys, WASD movement) ✅
- **`menu_select.mp3`** - Selection confirmation sound (Enter, Space, Click) ✅
- **`menu_error.mp3`** - Error/invalid action sound ✅
- **`beep.mp3`** - Used for back/cancel sound ✅

#### **Combat Sound Effects:**
- **`sword_swoosh.mp3`** - Sword/melee attack sound ✅
- **`sword_critical.mp3`** - Critical sword hit sound ✅
- **`gun_shot.mp3`** - Gun/ranged attack sound ✅
- **`gun_critical_hit.mp3`** - Critical gun hit sound ✅
- **`block.mp3`** - Shield/defensive block sound ✅

### **🔄 Placeholder Tracks (Using ObservingTheStar):**
- **Menu background music** - `start_background_music("menu")`
- **Starmap background music** - `start_background_music("starmap")`
- **Combat background music** - Placeholder entry ready
- **Dialog ambient music** - Placeholder entry ready

## Missing Sounds Inventory

### **🎵 Background Music Missing:**

#### **High Priority:**
- **Combat Music** - Intense, energetic track for turn-based combat
- **Dialog/Story Music** - Subtle, ambient background for narrative scenes

#### **Medium Priority:**  
- **Victory/Success Music** - Short track for mission completion
- **Defeat/Game Over Music** - Somber track for failure states
- **Menu Ambient** - Different track from starmap if variety desired

### **🔊 Sound Effects Missing:**

#### **High Priority (Most Noticeable):**
1. ~~**`menu_beep`** - Navigation sound~~ ✅ **COMPLETED**
2. ~~**`menu_select`** - Selection confirmation sound~~ ✅ **COMPLETED** 
3. ~~**`impact_hit`** - Successful attack hit sound~~ ✅ **COMPLETED** (using existing sounds)
4. ~~**`sword_swing`** - Weapon attack sound~~ ✅ **COMPLETED**

#### **Medium Priority:**
5. ~~**`menu_back`** - Back/cancel sound~~ ✅ **COMPLETED** (using beep.mp3)
6. ~~**`menu_error`** - Error/invalid action sound~~ ✅ **COMPLETED**
7. ~~**`critical_hit`** - Special sound for critical damage~~ ✅ **COMPLETED** (sword & gun versions)
8. **`enemy_death`** - Enemy defeat sound
9. **`level_up`** - Character level advancement sound
10. **`weapon_equip`** - Equipment change sound

#### **Low Priority (Polish & Atmosphere):**
11. **`footsteps`** - Character movement sound
12. **`door_open`** - Environmental interaction
13. **`item_pickup`** - Loot collection sound
14. **`spell_cast`** - Magic ability sound
15. **`shield_block`** - Defensive action sound
16. **`ambient_space`** - Background space atmosphere
17. **`ship_hum`** - Continuous ambient ship sounds
18. **`notification`** - General UI notification sound

## Implementation Guide

### **Adding New Background Music:**

1. **Import to GameMaker:**
   - Drag audio file into GameMaker IDE
   - Create Sound resource (ensure proper naming)

2. **Add to Audio Database:**
   ```gml
   // In init_audio_database() function
   new_area_music: {
       file: "GameMaker_Sound_Resource_Name",
       type: "music",
       loop: true,
       volume: 0.6  // Adjust 0.0-1.0
   }
   ```

3. **Use in Room:**
   ```gml
   // In Room Creation Code
   start_background_music("new_area_music");
   ```

### **Adding New Sound Effects:**

1. **Import to GameMaker:**
   - Create Sound resource with descriptive name

2. **Add to Audio Database:**
   ```gml
   // In init_audio_database() function  
   new_sound_effect: {
       file: "GameMaker_Sound_Resource_Name",
       type: "sfx",
       loop: false,  // Usually false for SFX
       volume: 0.8   // Adjust 0.0-1.0
   }
   ```

3. **Use in Game Code:**
   ```gml
   // Anywhere in game logic
   play_sound_effect("new_sound_effect");
   ```

## Volume Control System

### **Global Settings:**
- **`global.audio_settings.master_volume`** - Overall volume (0.0-1.0)
- **`global.audio_settings.music_volume`** - Background music only
- **`global.audio_settings.sfx_volume`** - Sound effects only  
- **`global.audio_settings.music_enabled`** - Music on/off toggle
- **`global.audio_settings.sfx_enabled`** - SFX on/off toggle

### **Control Functions:**
```gml
// Volume adjustment (0.0 to 1.0)
set_master_volume(0.8);
set_music_volume(0.6); 
set_sfx_volume(0.9);

// Enable/disable toggles
toggle_music(true);   // Enable music
toggle_sfx(false);    // Disable sound effects

// Playback control
stop_background_music();
```

## Current Room Audio Setup

### **Room_MainMenu:**
- Calls `start_background_music("menu")` on room start
- Uses ObservingTheStar track at 60% volume

### **Room_StarMap:**  
- Calls `start_background_music("starmap")` on room start
- Uses ObservingTheStar track at 50% volume (slightly quieter)

### **Other Rooms:**
- No background music currently configured
- Ready to add with simple `start_background_music()` calls

## Menu Integration

The existing menu system is already wired to use the audio functions:

- **Navigation** → `play_menu_navigate_sound()` ✅ **WORKING**
- **Selection** → `play_menu_select_sound()` ✅ **WORKING**  
- **Back/Cancel** → `play_menu_back_sound()` ✅ **WORKING**
- **Error** → `play_menu_error_sound()` ✅ **WORKING**

All menu sounds are now functional with the imported audio files!

## Combat Audio Integration

Combat audio is now fully functional with multiple weapon types supported:

### **Generic Combat Functions:**
- **Any weapon attack** → `play_weapon_attack_sound("sword")` or `play_weapon_attack_sound("gun")` ✅ **WORKING**
- **Any critical hit** → `play_critical_hit_sound("sword")` or `play_critical_hit_sound("gun")` ✅ **WORKING**
- **Blocking/Defense** → `play_block_sound()` ✅ **WORKING**

### **Specific Combat Functions:**
- **Sword attack** → `play_sword_attack_sound()` ✅ **WORKING**
- **Sword critical** → `play_sword_critical_sound()` ✅ **WORKING**
- **Gun attack** → `play_gun_attack_sound()` ✅ **WORKING**
- **Gun critical** → `play_gun_critical_sound()` ✅ **WORKING**
- **Shield block** → `play_block_sound()` ✅ **WORKING**

### **Direct Sound Effect Access:**
- **Weapon attacks** → `play_sound_effect("sword_swing")` or `play_sound_effect("gun_shot")`
- **Critical hits** → `play_sound_effect("sword_critical")` or `play_sound_effect("gun_critical")`
- **Blocking** → `play_sound_effect("block")`
- **Combat music** → `start_background_music("combat")` (placeholder track)

## Recommended Implementation Order

### **Phase 1 - Essential Feedback:** ✅ **COMPLETED**
1. ~~Import basic menu navigation sounds (beep, select, back)~~ ✅ **DONE**
2. ~~Add combat hit sound for immediate feedback~~ ✅ **DONE**
3. ~~Test volume controls work properly~~ ✅ **READY FOR TESTING**

### **Phase 2 - Combat Audio:** 🔄 **IN PROGRESS** 
1. Add dedicated combat background music 🔄 **PENDING**
2. ~~Add weapon swing sound~~ ✅ **DONE** (sword & gun variants)
3. ~~Add critical hit and enemy death sounds~~ ✅ **DONE** (critical hits completed, enemy death pending)

### **Phase 3 - Polish & Atmosphere:**
1. Add ambient space/ship sounds
2. Add environmental interaction sounds
3. Add notification and UI polish sounds

### **Phase 4 - Advanced Features:**
1. Implement audio settings menu integration
2. Add positional audio if needed
3. Add dynamic music system (combat intensity, etc.)

## Technical Notes

### **Error Handling:**
- System gracefully handles missing sound resources
- Debug messages indicate which sounds need importing
- Game continues to function without audio assets

### **Performance:**
- Audio resources loaded on-demand
- Automatic cleanup of finished sound effects
- Background music tracked to prevent duplicate playback

### **GameMaker Integration:**
- Uses `asset_get_index()` for dynamic sound resource lookup
- Compatible with GameMaker's built-in audio system
- Supports all GameMaker audio formats (OGG, WAV, MP3)

## Future Enhancements

### **Planned Features:**
- **Audio settings menu** - Player-adjustable volume controls
- **Dynamic music system** - Music that responds to game state
- **Positional audio** - 3D sound positioning for immersion
- **Audio scripting** - Event-driven audio sequences
- **Compression optimization** - Automatic audio file optimization

This system provides a solid foundation that can grow with the game's audio needs while maintaining clean, maintainable code.