// obj_GameController Room Start Event
// Handle room transitions through event bus

show_debug_message("GameController: Room started - " + room_get_name(room));

// Update navigation state
switch(room) {
    case Room_MainMenu: global.nav.state = GameState.MAIN_MENU; break;
    case Room_StarMap:  global.nav.state = GameState.STARMAP; break;
    case Room_Dialog:   global.nav.state = GameState.DIALOG; break;
    case Room1:         global.nav.state = GameState.OVERWORLD; break;
    default:            global.nav.state = GameState.OVERWORLD; break;
}

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
}

// Emit room initialized event for auto-save
scr_event_emit("room_initialized", {room: room});

// Room-specific handlers
function handle_star_map_entry() {
    show_debug_message("GameController: Entering star map - loading saved progress");
    
    // Ensure star map state exists
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    // If we have a saved game, apply it
    if (file_exists("save_slot_0.sav")) {
        global.should_load_star_map_state = true;
    }
    
    // Update last checkpoint
    if (variable_global_exists("game_progress")) {
        global.game_progress.last_checkpoint = get_current_star_system();
    }
    
    mark_progress_dirty();
}

function handle_combat_room_entry() {
    show_debug_message("GameController: Entering combat room");
    
    // Apply any pending save data via event bus
    if (variable_global_exists("pending_save_data") && variable_global_exists("loading_save")) {
        if (global.loading_save) {
            // Emit save data loaded event with slight delay
            alarm[1] = game_get_speed(gamespeed_fps) * 0.5; // 0.5 second delay
        }
    }
}

function handle_dialog_room_entry() {
    show_debug_message("GameController: Entering dialog room");
    
    // Ensure dialog system is initialized
    if (!variable_global_exists("dialog_flags")) {
        init_dialog_system();
    }
}