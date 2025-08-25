// Comprehensive Audio System - Easily Extendable
// Handles both background music and sound effects with volume control

// Global audio settings - initialize if not exist
if (!variable_global_exists("audio_settings")) {
    global.audio_settings = {
        master_volume: 1.0,
        music_volume: 0.7,
        sfx_volume: 0.8,
        music_enabled: true,
        sfx_enabled: true
    };
}

// Current background music tracking
if (!variable_global_exists("current_bg_music")) {
    global.current_bg_music = {
        track: "",
        audio_id: -1,
        volume: 0.7
    };
}

// Audio track database - easily extendable
function init_audio_database() {
    if (!variable_global_exists("audio_tracks")) {
        global.audio_tracks = {
            // Background Music
            menu: {
                file: "ObservingTheStar",  // Will look for ObservingTheStar resource
                type: "music",
                loop: true,
                volume: 0.6
            },
            starmap: {
                file: "ObservingTheStar",  // Same track for now, easily changeable
                type: "music", 
                loop: true,
                volume: 0.5
            },
            combat: {
                file: "ObservingTheStar",  // Placeholder - replace with combat music
                type: "music",
                loop: true, 
                volume: 0.7
            },
            dialog: {
                file: "ObservingTheStar",  // Placeholder - replace with ambient dialog music
                type: "music",
                loop: true,
                volume: 0.3
            },
            
            // Sound Effects - now with actual imported sounds!
            menu_navigate: {
                file: "menu_beep",  // ✅ Available - menu navigation sound
                type: "sfx",
                loop: false,
                volume: 0.8
            },
            menu_select: {
                file: "menu_select",  // ✅ Available - menu selection sound
                type: "sfx", 
                loop: false,
                volume: 0.9
            },
            menu_back: {
                file: "beep",  // ✅ Available - using beep for back sound
                type: "sfx",
                loop: false,
                volume: 0.7
            },
            menu_error: {
                file: "menu_error",  // ✅ Available - menu error sound
                type: "sfx",
                loop: false,
                volume: 0.8
            },
            
            // Combat Sound Effects
            sword_swing: {
                file: "sword_swoosh",  // ✅ Available - sword attack sound
                type: "sfx",
                loop: false,
                volume: 0.7
            },
            sword_critical: {
                file: "sword_critical",  // ✅ Available - critical sword hit
                type: "sfx",
                loop: false,
                volume: 0.9
            },
            gun_shot: {
                file: "gun_shot",  // ✅ Available - ranged weapon sound
                type: "sfx",
                loop: false,
                volume: 0.8
            },
            gun_critical: {
                file: "gun_critical_hit",  // ✅ Available - critical gun hit
                type: "sfx",
                loop: false,
                volume: 0.9
            },
            block: {
                file: "block",  // ✅ Available - shield/block sound
                type: "sfx",
                loop: false,
                volume: 0.8
            },
            
            // Legacy entries for compatibility
            weapon_swing: {
                file: "sword_swoosh",  // Alias for sword_swing
                type: "sfx",
                loop: false,
                volume: 0.7
            },
            enemy_hit: {
                file: "sword_swoosh",  // Temporary - can be changed to impact sound later
                type: "sfx",
                loop: false,
                volume: 0.6
            }
        };
    }
}

// Start background music with smooth transitions
function start_background_music(track_name) {
    init_audio_database();
    
    if (!global.audio_settings.music_enabled) {
        show_debug_message("Background music disabled - skipping: " + track_name);
        return;
    }
    
    // Don't restart the same track
    if (global.current_bg_music.track == track_name && audio_is_playing(global.current_bg_music.audio_id)) {
        show_debug_message("Track already playing: " + track_name);
        return;
    }
    
    // Stop current music with fade out
    if (global.current_bg_music.audio_id != -1 && audio_is_playing(global.current_bg_music.audio_id)) {
        audio_sound_gain(global.current_bg_music.audio_id, 0, 500);  // Fade out over 500ms
        // Note: In a full implementation, you'd use an alarm to actually stop the audio after fade
        audio_stop_sound(global.current_bg_music.audio_id);
    }
    
    // Get track info
    if (!variable_struct_exists(global.audio_tracks, track_name)) {
        show_debug_message("ERROR: Audio track not found: " + track_name);
        return;
    }
    
    var track_info = global.audio_tracks[$ track_name];
    
    // Try to play the audio (for now, this will fail until the sound is properly imported)
    var audio_id = -1;
    try {
        // This will need to reference the actual GameMaker sound resource
        // For now, we'll use a placeholder that matches the file name
        if (asset_get_index(track_info.file) != -1) {
            audio_id = audio_play_sound(asset_get_index(track_info.file), 10, track_info.loop);
            if (audio_id != -1) {
                var final_volume = track_info.volume * global.audio_settings.music_volume * global.audio_settings.master_volume;
                audio_sound_gain(audio_id, final_volume, 0);
                show_debug_message("Started background music: " + track_name + " (Volume: " + string(final_volume) + ")");
            }
        } else {
            show_debug_message("Audio resource not found: " + track_info.file + " - Please import sound into GameMaker");
        }
    } catch(e) {
        show_debug_message("Failed to play audio: " + track_name + " - " + string(e));
    }
    
    // Update current music tracking
    global.current_bg_music = {
        track: track_name,
        audio_id: audio_id,
        volume: track_info.volume
    };
}

// Play sound effect
function play_sound_effect(sfx_name) {
    init_audio_database();
    
    if (!global.audio_settings.sfx_enabled) {
        return;
    }
    
    // Get SFX info
    if (!variable_struct_exists(global.audio_tracks, sfx_name)) {
        show_debug_message("ERROR: Sound effect not found: " + sfx_name);
        return;
    }
    
    var sfx_info = global.audio_tracks[$ sfx_name];
    
    if (sfx_info.type != "sfx") {
        show_debug_message("ERROR: " + sfx_name + " is not a sound effect");
        return;
    }
    
    // Try to play the sound effect
    try {
        if (asset_get_index(sfx_info.file) != -1) {
            var audio_id = audio_play_sound(asset_get_index(sfx_info.file), 5, sfx_info.loop);
            if (audio_id != -1) {
                var final_volume = sfx_info.volume * global.audio_settings.sfx_volume * global.audio_settings.master_volume;
                audio_sound_gain(audio_id, final_volume, 0);
                show_debug_message("Played SFX: " + sfx_name + " (Volume: " + string(final_volume) + " = " + string(sfx_info.volume) + " * " + string(global.audio_settings.sfx_volume) + " * " + string(global.audio_settings.master_volume) + ")");
            }
        } else {
            show_debug_message("SFX resource not found: " + sfx_info.file);
        }
    } catch(e) {
        show_debug_message("Failed to play SFX: " + sfx_name + " - " + string(e));
    }
}

// Stop background music
function stop_background_music() {
    if (global.current_bg_music.audio_id != -1) {
        audio_stop_sound(global.current_bg_music.audio_id);
        global.current_bg_music = {
            track: "",
            audio_id: -1,
            volume: 0.7
        };
        show_debug_message("Stopped background music");
    }
}

// Set audio volumes (0.0 to 1.0)
function set_master_volume(volume) {
    global.audio_settings.master_volume = clamp(volume, 0.0, 1.0);
    // Update current music volume if playing
    if (global.current_bg_music.audio_id != -1 && audio_is_playing(global.current_bg_music.audio_id)) {
        var track_info = global.audio_tracks[$ global.current_bg_music.track];
        var final_volume = track_info.volume * global.audio_settings.music_volume * global.audio_settings.master_volume;
        audio_sound_gain(global.current_bg_music.audio_id, final_volume, 100);
    }
}

function set_music_volume(volume) {
    var old_volume = global.audio_settings.music_volume;
    global.audio_settings.music_volume = clamp(volume, 0.0, 1.0);
    show_debug_message("Music volume changed from " + string(old_volume) + " to " + string(global.audio_settings.music_volume));
    
    // Update current music volume if playing
    if (global.current_bg_music.audio_id != -1 && audio_is_playing(global.current_bg_music.audio_id)) {
        var track_info = global.audio_tracks[$ global.current_bg_music.track];
        var final_volume = track_info.volume * global.audio_settings.music_volume * global.audio_settings.master_volume;
        audio_sound_gain(global.current_bg_music.audio_id, final_volume, 100);
        show_debug_message("Updated playing music volume to: " + string(final_volume));
    }
}

function set_sfx_volume(volume) {
    var old_volume = global.audio_settings.sfx_volume;
    global.audio_settings.sfx_volume = clamp(volume, 0.0, 1.0);
    show_debug_message("SFX volume changed from " + string(old_volume) + " to " + string(global.audio_settings.sfx_volume));
}

// Toggle audio on/off
function toggle_music(enabled) {
    global.audio_settings.music_enabled = enabled;
    if (!enabled) {
        stop_background_music();
    }
}

function toggle_sfx(enabled) {
    global.audio_settings.sfx_enabled = enabled;
}

// Enhanced menu sound functions using the new system
function play_menu_navigate_sound() {
    play_sound_effect("menu_navigate");
}

function play_menu_select_sound() {
    play_sound_effect("menu_select");
}

function play_menu_back_sound() {
    play_sound_effect("menu_back");
}

function play_menu_error_sound() {
    play_sound_effect("menu_error");
}

// Combat sound functions for easy use in combat system
function play_sword_attack_sound() {
    play_sound_effect("sword_swing");
}

function play_sword_critical_sound() {
    play_sound_effect("sword_critical");
}

function play_gun_attack_sound() {
    play_sound_effect("gun_shot");
}

function play_gun_critical_sound() {
    play_sound_effect("gun_critical");
}

function play_block_sound() {
    play_sound_effect("block");
}

// Generic combat functions that choose appropriate sound
function play_weapon_attack_sound(weapon_type) {
    switch(weapon_type) {
        case "sword":
        case "melee":
            play_sword_attack_sound();
            break;
        case "gun":
        case "ranged":
            play_gun_attack_sound();
            break;
        default:
            play_sword_attack_sound(); // Default to sword
            break;
    }
}

function play_critical_hit_sound(weapon_type) {
    switch(weapon_type) {
        case "sword":
        case "melee":
            play_sword_critical_sound();
            break;
        case "gun":
        case "ranged":
            play_gun_critical_sound();
            break;
        default:
            play_sword_critical_sound(); // Default to sword
            break;
    }
}

// Audio testing functions for debugging
function test_all_sounds() {
    show_debug_message("=== TESTING ALL SOUNDS ===");
    show_debug_message("Current audio settings - Master: " + string(global.audio_settings.master_volume) + ", Music: " + string(global.audio_settings.music_volume) + ", SFX: " + string(global.audio_settings.sfx_volume));
    
    show_debug_message("Testing menu sounds...");
    play_menu_navigate_sound();
    
    // Delay for testing sequence (use alarms in practice)
    show_debug_message("Test completed - check debug output for volume calculations");
}

function test_volume_settings() {
    show_debug_message("=== TESTING VOLUME SETTINGS ===");
    
    // Test SFX volume change
    show_debug_message("Testing SFX volume...");
    set_sfx_volume(0.3);
    play_menu_select_sound();
    
    set_sfx_volume(0.8); 
    play_menu_select_sound();
    
    // Test music volume change  
    show_debug_message("Testing music volume...");
    set_music_volume(0.2);
    set_music_volume(0.9);
    
    show_debug_message("Volume test completed");
}

function test_combat_sounds() {
    show_debug_message("=== TESTING COMBAT SOUNDS ===");
    play_sword_attack_sound();
    play_gun_attack_sound(); 
    play_sword_critical_sound();
    play_gun_critical_sound();
    play_block_sound();
    show_debug_message("Combat sound test completed");
}