// obj_GameManager Create Event  
// Persistent singleton managing game state and progression

// Ensure singleton pattern - only one GameManager exists
if (instance_number(obj_GameManager) > 1) {
    instance_destroy();
    return;
}

// Mark this as the global game manager reference BEFORE initialization
global.game_manager = id;

// Initialize active save slot (defaults to 1 if not set)
if (!variable_global_exists("active_save_slot")) {
    global.active_save_slot = 1;
}

// Initialize game progression tracking
game_version = "1.0";
session_start_time = get_timer();

// Auto-save configuration
auto_save_enabled = true;
auto_save_interval = 300; // 5 minutes in seconds
last_auto_save_time = 0;

// Progress tracking flags
progress_dirty = false; // Set to true when progress needs saving
last_save_time = 0;
save_in_progress = false;

// Defer initialization to avoid circular dependency
alarm[2] = 1; // Initialize systems after 1 frame

show_debug_message("GameManager singleton created - managing game progression");

// Initialize all global systems
function initialize_global_systems() {
    show_debug_message("Initializing global game systems...");
    
    // Initialize dialog system
    if (script_exists(init_dialog_system)) {
        init_dialog_system();
    }
    
    // Initialize star map system
    if (script_exists(init_star_map)) {
        init_star_map();
    }
    
    // Initialize weapon system
    if (script_exists(init_weapons)) {
        init_weapons();
    }
    
    // Initialize global game settings if they don't exist
    if (!variable_global_exists("game_settings")) {
        global.game_settings = {
            difficulty: 1,
            auto_save: true,
            sound_enabled: true,
            music_enabled: true
        };
    }
    
    // Initialize progress tracking flags
    if (!variable_global_exists("game_progress")) {
        global.game_progress = {
            sessions_played: 0,
            total_playtime: 0,
            systems_unlocked: 1,
            dialogs_completed: 0,
            combats_won: 0,
            last_checkpoint: "system_001"
        };
    }
    
    show_debug_message("Global systems initialized");
}

// Auto-save game progress at key moments
function auto_save_progress() {
    if (!auto_save_enabled || save_in_progress) {
        return false;
    }
    
    // Don't auto-save if we're still in the initialization phase
    if (!variable_global_exists("star_map_state") || room == Room_MainMenu) {
        show_debug_message("Auto-save skipped - still initializing");
        return false;
    }
    
    if (progress_dirty || (get_timer() - last_auto_save_time) > (auto_save_interval * 1000000)) {
        save_in_progress = true;
        // Use active save slot instead of hardcoded slot 0
        var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
        var success = save_game_to_slot(slot_to_use);
        
        if (success) {
            progress_dirty = false;
            last_auto_save_time = get_timer();
            last_save_time = get_timer();
            show_debug_message("Auto-save completed successfully");
        } else {
            show_debug_message("Auto-save failed!");
        }
        
        save_in_progress = false;
        return success;
    }
    
    return false;
}

// Mark progress as needing save
function mark_progress_dirty() {
    progress_dirty = true;
    show_debug_message("Progress marked as dirty - needs saving");
}

// Handle dialog completion
function on_dialog_completed(scene_id, dialog_effects) {
    show_debug_message("GameManager: Dialog completed - " + scene_id);
    
    // Update progress counters
    if (variable_global_exists("game_progress")) {
        global.game_progress.dialogs_completed++;
        show_debug_message("Total dialogs completed: " + string(global.game_progress.dialogs_completed));
    }
    
    // Process any system unlocks or progression from dialog
    if (is_struct(dialog_effects)) {
        show_debug_message("Processing dialog effects for progression");
        process_dialog_progression_effects(dialog_effects);
    } else {
        show_debug_message("No dialog effects to process");
    }
    
    // Mark as needing save
    mark_progress_dirty();
    show_debug_message("GameManager: Marked progress as dirty, will auto-save");
    
    // Auto-save after dialog completion
    auto_save_progress();
}

// Handle combat completion
function on_combat_completed(victory, xp_awarded) {
    show_debug_message("GameManager: Combat completed - Victory: " + string(victory) + ", XP: " + string(xp_awarded));
    
    // Update progress counters
    if (variable_global_exists("game_progress") && victory) {
        global.game_progress.combats_won++;
    }
    
    // Mark as needing save
    mark_progress_dirty();
    
    // Auto-save after combat
    auto_save_progress();
}

// Handle system unlock progression
function on_system_unlocked(system_id) {
    show_debug_message("GameManager: System unlocked - " + system_id);
    
    // Update progress counters
    if (variable_global_exists("game_progress")) {
        global.game_progress.systems_unlocked++;
    }
    
    // Mark as needing save
    mark_progress_dirty();
}

// Process dialog effects for progression
function process_dialog_progression_effects(dialog_effects) {
    if (!is_struct(dialog_effects)) return;
    
    var effect_names = variable_struct_get_names(dialog_effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var effect_value = dialog_effects[$ effect_name];
        
        show_debug_message("Processing dialog effect: " + effect_name + " = " + string(effect_value));
        
        // Handle system unlocks based on story progression
        switch(effect_name) {
            case "ending":
                // Different endings may unlock different follow-up systems
                handle_ending_progression(effect_value);
                break;
                
            case "independent_path":
                if (effect_value) {
                    unlock_star_system("system_003"); // Independent path unlocks
                }
                break;
                
            case "followed_protocol":
                if (effect_value) {
                    unlock_star_system("system_008"); // Earth Command path
                }
                break;
                
            default:
                // Check if this is a generic progression trigger
                if (effect_value && (effect_name == "prometheus_explored" || effect_name == "dialog_completed")) {
                    unlock_next_sequential_system();
                }
                break;
        }
    }
}

// Handle different story endings for progression
function handle_ending_progression(ending_type) {
    show_debug_message("Processing ending progression: " + ending_type);
    
    switch(ending_type) {
        case "reported_to_earth":
            unlock_star_system("system_008"); // Earth Command becomes available
            break;
            
        case "independent_boarding":
            unlock_star_system("system_002"); // Independent investigation path
            unlock_star_system("system_009"); // Alternative systems
            break;
            
        default:
            // Generic progression - unlock next system in sequence
            unlock_next_sequential_system();
            break;
    }
}

// Unlock next system in sequence
function unlock_next_sequential_system() {
    // Simple progression - unlock systems in order
    var unlocked_count = 0;
    if (variable_global_exists("star_map_state") && variable_struct_exists(global.star_map_state, "systems")) {
        var systems = global.star_map_state.systems;
        var system_ids = variable_struct_get_names(systems);
        
        for (var i = 0; i < array_length(system_ids); i++) {
            if (systems[$ system_ids[i]].unlocked) {
                unlocked_count++;
            }
        }
    }
    
    // Unlock next system in sequence
    var next_system_id = "system_" + string_format(unlocked_count + 1, 3, 0);
    if (unlocked_count < 10) { // Max 10 systems
        unlock_star_system(next_system_id);
    }
}

// Force immediate save
function force_save() {
    show_debug_message("GameManager: Forcing immediate save...");
    save_in_progress = true;
    // Use active save slot instead of hardcoded slot 0
    var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
    var success = save_game_to_slot(slot_to_use);
    save_in_progress = false;
    
    if (success) {
        progress_dirty = false;
        last_save_time = get_timer();
        show_debug_message("Force save completed");
    } else {
        show_debug_message("Force save failed!");
    }
    
    return success;
}

// Load game state (called when entering main gameplay)
function load_game_state() {
    show_debug_message("GameManager: Loading game state...");
    
    // Try to load from active save slot
    var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
    var save_file = "save_slot_" + string(slot_to_use) + ".sav";
    
    if (file_exists(save_file)) {
        var success = load_game_from_slot_data(slot_to_use);
        if (success) {
            show_debug_message("Game state loaded from slot " + string(slot_to_use));
            return true;
        }
    }
    
    show_debug_message("No saved game state found - starting fresh");
    return false;
}

// Get save status for UI
function get_save_status() {
    if (save_in_progress) return "Saving...";
    if (progress_dirty) return "Unsaved changes";
    
    var time_since_save = (get_timer() - last_save_time) / 1000000;
    if (time_since_save < 10) return "Recently saved";
    if (time_since_save < 300) return "Auto-save ready";
    
    return "Ready";
}