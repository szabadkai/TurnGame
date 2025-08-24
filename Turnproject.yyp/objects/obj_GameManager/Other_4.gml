// obj_GameManager Room Start Event
// Handle room transitions and state loading

show_debug_message("GameManager: Room started - " + room_get_name(room));

// Handle specific room initialization
switch(room) {
    case Room_StarMap:
        handle_star_map_entry();
        break;
        
    case Room1: // Combat room
        handle_combat_room_entry();
        break;
        
    case Room_Dialog:
        handle_dialog_room_entry();
        break;
        
    case Room_MainMenu:
        // Main menu doesn't need special handling
        break;
}

// Auto-save when entering significant rooms (but not main menu)
if (room != Room_MainMenu && progress_dirty) {
    // Delay auto-save by 1 second to let room fully initialize
    alarm[0] = game_get_speed(gamespeed_fps) * 1; // 1 second delay
}

// Handle star map room entry
function handle_star_map_entry() {
    show_debug_message("GameManager: Entering star map - loading saved progress");
    
    // Ensure star map state exists
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    // If we have a saved game, apply it
    if (file_exists("save_slot_0.sav")) {
        // Set flag for star map manager to load state
        global.should_load_star_map_state = true;
    }
    
    // Update last checkpoint
    if (variable_global_exists("game_progress")) {
        global.game_progress.last_checkpoint = get_current_star_system();
    }
    
    mark_progress_dirty();
}

// Handle combat room entry
function handle_combat_room_entry() {
    show_debug_message("GameManager: Entering combat room");
    
    // Apply any pending save data
    if (variable_global_exists("pending_save_data") && variable_global_exists("loading_save")) {
        if (global.loading_save) {
            // Delay applying save data to let room initialize
            alarm[1] = game_get_speed(gamespeed_fps) * 0.5; // 0.5 second delay
        }
    }
}

// Handle dialog room entry
function handle_dialog_room_entry() {
    show_debug_message("GameManager: Entering dialog room");
    
    // Ensure dialog system is initialized
    if (!variable_global_exists("dialog_flags")) {
        init_dialog_system();
    }
}