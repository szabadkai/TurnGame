// Navigation service for room/state transitions

function scr_nav_init() {
  if (!variable_global_exists("nav")) {
    global.nav = {
      state: undefined,
      prev_state: undefined,
      payload: undefined,
      stack: []
    };
  }
}

function scr_nav_room_for_state(_state) {
  switch (_state) {
    case GameState.MAIN_MENU: return Room_MainMenu;
    case GameState.OVERWORLD: return Room1;
    case GameState.STARMAP:   return Room_StarMap;
    case GameState.DIALOG:    return Room_Dialog;
    case GameState.COMBAT:    return Room1;
    default:                  return room;
  }
}

function scr_nav_go(_state, _payload) {
  scr_nav_init();
  var _current = global.nav.state;
  if (_current != undefined) {
    array_push(global.nav.stack, _current);
  }
  global.nav.prev_state = _current;
  global.nav.state = _state;
  global.nav.payload = _payload;

  var _target_room = scr_nav_room_for_state(_state);
  if (_target_room != room) {
    room_goto(_target_room);
  }
}

function scr_nav_back() {
  scr_nav_init();
  if (array_length(global.nav.stack) > 0) {
    var _state = array_pop(global.nav.stack);
    global.nav.prev_state = global.nav.state;
    global.nav.state = _state;
    var _target_room = scr_nav_room_for_state(_state);
    if (_target_room != room) {
      room_goto(_target_room);
    }
  }
}



// Helper to get current state
function scr_nav_current_state() {
  scr_nav_init();
  return global.nav.state;
}

// Helper to get payload
function scr_nav_get_payload() {
  scr_nav_init();
  return global.nav.payload;
}

// Helper to check if we came from a specific state
function scr_nav_came_from(_state) {
  scr_nav_init();
  return global.nav.prev_state == _state;
}

// Helper to clear navigation history
function scr_nav_clear_history() {
  scr_nav_init();
  global.nav.stack = [];
}
// Menu system support functions

// Change menu state with transition
function change_menu_state(new_state) {
    if (menu_state == new_state) return;
    
    previous_menu_state = new_state;
    menu_state = MENUSTATE.TRANSITION;
    transition_direction = -1;
    selected_option = 0;
}

// Update current options array based on menu state
function update_current_options() {
    switch (menu_state) {
        case MENUSTATE.MAIN:
            current_options = main_menu_options;
            break;
        case MENUSTATE.SETTINGS:
            current_options = settings_options;
            break;
        case MENUSTATE.SETTINGS_AUDIO:
            current_options = audio_options;
            break;
        case MENUSTATE.SETTINGS_GRAPHICS:
            current_options = graphics_options;
            break;
        case MENUSTATE.SETTINGS_CONTROLS:
            current_options = controls_options;
            break;
        case MENUSTATE.SETTINGS_GAMEPLAY:
            current_options = gameplay_options;
            break;
        case MENUSTATE.SAVE_LOAD:
            current_options = ["Slot 1", "Slot 2", "Slot 3", "Back"];
            break;
        case MENUSTATE.QUIT_CONFIRM:
            current_options = ["Yes", "No"];
            break;
        default:
            current_options = main_menu_options;
            break;
    }
}

// Get menu title based on current state
function get_menu_title() {
    // Use base menu function if it exists, otherwise use original logic
    if (variable_instance_exists(id, "menu_context")) {
        return get_menu_title_base();
    } else {
        // Original main menu logic
        switch (menu_state) {
            case MENUSTATE.MAIN:
                return "TURN PROJECT";
            case MENUSTATE.SETTINGS:
                return "SETTINGS";
            case MENUSTATE.SETTINGS_AUDIO:
                return "AUDIO SETTINGS";
            case MENUSTATE.SETTINGS_GRAPHICS:
                return "GRAPHICS SETTINGS";
            case MENUSTATE.SETTINGS_CONTROLS:
                return "CONTROLS";
            case MENUSTATE.SETTINGS_GAMEPLAY:
                return "GAMEPLAY";
            case MENUSTATE.SAVE_LOAD:
                return "LOAD GAME";
            case MENUSTATE.QUIT_CONFIRM:
                return "QUIT GAME?";
            default:
                return "MENU";
        }
    }
}

// Check if an option should be disabled
function is_option_disabled(option_index) {
    switch (menu_state) {
        case MENUSTATE.MAIN:
            if (option_index == MAINMENU_OPTION.CONTINUE) {
                return !has_save_files();
            }
            break;
        case MENUSTATE.SAVE_LOAD:
            if (option_index < 3) {
                return !save_slot_exists(option_index + 1); // Convert 0-2 to slots 1-3
            }
            break;
    }
    return false;
}

// Get display text for an option (with values for settings)
function get_option_display_text(option_index) {
    var base_text = current_options[option_index];
    
    switch (menu_state) {
        case MENUSTATE.SETTINGS_AUDIO:
            switch (option_index) {
                case AUDIO_OPTION.MASTER_VOLUME:
                    return base_text + ": " + string(round(global.game_settings.master_volume * 100)) + "%";
                case AUDIO_OPTION.SFX_VOLUME:
                    return base_text + ": " + string(round(global.game_settings.sfx_volume * 100)) + "%";
                case AUDIO_OPTION.MUSIC_VOLUME:
                    return base_text + ": " + string(round(global.game_settings.music_volume * 100)) + "%";
            }
            break;
            
        case MENUSTATE.SETTINGS_GRAPHICS:
            switch (option_index) {
                case GRAPHICS_OPTION.FULLSCREEN:
                    return base_text + ": " + (global.game_settings.fullscreen ? "ON" : "OFF");
            }
            break;
            
        case MENUSTATE.SETTINGS_GAMEPLAY:
            switch (option_index) {
                case GAMEPLAY_OPTION.COMBAT_SPEED:
                    var speed_names = ["Slow", "Normal", "Fast"];
                    var speed_index = clamp(floor(global.game_settings.combat_speed), 0, 2);
                    return base_text + ": " + speed_names[speed_index];
                case GAMEPLAY_OPTION.AUTO_SAVE:
                    return base_text + ": " + (global.game_settings.auto_save ? "ON" : "OFF");
                case GAMEPLAY_OPTION.DIFFICULTY:
                    var diff_names = ["Easy", "Normal", "Hard"];
                    var diff_index = clamp(global.game_settings.difficulty, 0, 2);
                    return base_text + ": " + diff_names[diff_index];
            }
            break;
            
            
        case MENUSTATE.SAVE_LOAD:
            if (option_index < 3) {
                var slot_index = option_index + 1; // Convert 0-2 to slots 1-3
                if (save_slot_exists(slot_index)) {
                    var save_info = get_save_slot_info(slot_index);
                    var delete_hint = "";
                    
                    if (option_index == selected_option) {
                        // Check if this slot is awaiting delete confirmation
                        if (variable_global_exists("delete_confirm_slot") && global.delete_confirm_slot == slot_index) {
                            delete_hint = " [Press X again to DELETE!]";
                        } else {
                            delete_hint = " [X to delete]";
                        }
                    }
                    
                    return base_text + " - " + save_info + delete_hint;
                } else {
                    return base_text + " - Empty";
                }
            }
            break;
    }
    
    return base_text;
}

// Get instruction text for current menu
function get_instruction_text() {
    var base_instructions = "↑↓ Navigate • Enter Select";
    
    switch (menu_state) {
        case MENUSTATE.MAIN:
            return base_instructions;
        case MENUSTATE.SAVE_LOAD:
            return base_instructions + " • X Delete • Esc Back";
        case MENUSTATE.SETTINGS_AUDIO:
        case MENUSTATE.SETTINGS_GRAPHICS:
        case MENUSTATE.SETTINGS_GAMEPLAY:
            return "↑↓ Navigate • ←→ Change • Enter Select • Esc Back";
        default:
            return base_instructions + " • Esc Back";
    }
}

// Handle main menu selection (original)
function handle_main_menu_selection_original() {
    switch (selected_option) {
        case MAINMENU_OPTION.NEW_GAME:
            play_menu_select_sound();
            start_new_game();
            break;
        case MAINMENU_OPTION.CONTINUE:
            if (has_save_files()) {
                play_menu_select_sound();
                change_menu_state(MENUSTATE.SAVE_LOAD);
            } else {
                play_menu_error_sound();
            }
            break;
        case MAINMENU_OPTION.NEW_FIGHT:
            play_menu_select_sound();
            show_debug_message("Starting new fight for debugging...");
            scr_nav_go(GameState.COMBAT, undefined);
            break;
        case MAINMENU_OPTION.SETTINGS:
            play_menu_select_sound();
            change_menu_state(MENUSTATE.SETTINGS);
            break;
        case MAINMENU_OPTION.SCENE_GALLERY:
            play_menu_select_sound();
            // Launch scene selector directly by going to dialog room and starting selection
            start_scene_selection();
            scr_nav_go(GameState.DIALOG, undefined);
            break;
        case MAINMENU_OPTION.QUIT:
            play_menu_select_sound();
            change_menu_state(MENUSTATE.QUIT_CONFIRM);
            break;
    }
}

// Handle settings menu selection
function handle_settings_selection() {
    switch (selected_option) {
        case SETTINGS_OPTION.AUDIO:
            change_menu_state(MENUSTATE.SETTINGS_AUDIO);
            break;
        case SETTINGS_OPTION.GRAPHICS:
            change_menu_state(MENUSTATE.SETTINGS_GRAPHICS);
            break;
        case SETTINGS_OPTION.CONTROLS:
            change_menu_state(MENUSTATE.SETTINGS_CONTROLS);
            break;
        case SETTINGS_OPTION.GAMEPLAY:
            change_menu_state(MENUSTATE.SETTINGS_GAMEPLAY);
            break;
        case SETTINGS_OPTION.BACK:
            change_menu_state(MENUSTATE.MAIN);
            break;
    }
}

// Start new game
function start_new_game() {
    show_debug_message("Starting completely fresh new game...");
    
    // Find the next available save slot (1-3)
    var new_slot = get_next_available_save_slot();
    
    // Set this as the active save slot for this playthrough
    set_active_save_slot(new_slot);
    
    // If overwriting existing slot, delete it first
    if (save_slot_exists(new_slot)) {
        var save_file = "save_slot_" + string(new_slot) + ".sav";
        file_delete(save_file);
        show_debug_message("Overwriting existing save slot " + string(new_slot));
    }
    
    // Completely reset all global game state variables
    reset_all_global_state();
    
    // Initialize fresh star map system
    if (script_exists(init_star_map)) {
        init_star_map();
        show_debug_message("Initialized fresh star map system");
    }
    
    // Create initial save in the new slot
    if (script_exists(save_game_to_slot)) {
        save_game_to_slot(new_slot);
        show_debug_message("Created initial save in slot " + string(new_slot));
    }
    
    // Go to star map for fresh start
    scr_nav_go(GameState.STARMAP, undefined);
}

// Completely reset all global game state for fresh start
function reset_all_global_state() {
    show_debug_message("Resetting all global game state...");
    
    // Reset dialog system state
    if (variable_global_exists("dialog_flags")) {
        global.dialog_flags = {};
        show_debug_message("Reset dialog flags");
    }
    
    if (variable_global_exists("dialog_reputation")) {
        global.dialog_reputation = {};
        show_debug_message("Reset dialog reputation");
    }
    
    // Reset loop counter
    if (variable_global_exists("loop_count")) {
        global.loop_count = 0;
        show_debug_message("Reset loop count");
    }
    
    // Reset game progress tracking
    if (variable_global_exists("game_progress")) {
        global.game_progress = {
            sessions_played: 0,
            total_playtime: 0,
            systems_unlocked: 1,
            dialogs_completed: 0,
            combats_won: 0,
            last_checkpoint: "system_001"
        };
        show_debug_message("Reset game progress");
    }
    
    // Clear star map state - will be reinitialized fresh
    if (variable_global_exists("star_map_state")) {
        global.star_map_state = undefined;
        show_debug_message("Cleared star map state for fresh initialization");
    }
    
    // Reset any loading flags
    if (variable_global_exists("loading_save")) {
        global.loading_save = false;
    }
    
    if (variable_global_exists("pending_save_data")) {
        global.pending_save_data = undefined;
    }
    
    if (variable_global_exists("should_load_star_map_state")) {
        global.should_load_star_map_state = false;
    }
    
    show_debug_message("Global state reset complete");
}

// Check if save files exist (only check user slots 1-3, not auto-save slot 0)
function has_save_files() {
    for (var i = 1; i <= 3; i++) {
        if (save_slot_exists(i)) {
            return true;
        }
    }
    return false;
}

// Find the next available save slot (1-3)
function get_next_available_save_slot() {
    for (var i = 1; i <= 3; i++) {
        if (!save_slot_exists(i)) {
            show_debug_message("Found available save slot: " + string(i));
            return i;
        }
    }
    show_debug_message("All save slots full, using slot 1");
    return 1; // If all slots full, overwrite slot 1
}

// Set the active save slot for this playthrough
function set_active_save_slot(slot_index) {
    global.active_save_slot = slot_index;
    show_debug_message("Set active save slot to: " + string(slot_index));
}

// Check if specific save slot exists
function save_slot_exists(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    return file_exists(save_file);
}

// Get save slot info string
function get_save_slot_info(slot_index) {
    // Use the proper detailed save slot info function
    return get_save_slot_info_detailed(slot_index);
}

// Check all save slots
function check_save_slots() {
    save_slots = [];
    for (var i = 0; i < 3; i++) {
        array_push(save_slots, save_slot_exists(i));
    }
}

// Load menu background image
function load_menu_background_image() {
    // Get the current promo image filename
    var promo_filename = promo_images[current_promo_index] + ".png";
    
    // Try different paths for the selected promo image
    var image_paths = [
        promo_filename,                              // Included file by filename (primary)
        "datafiles/" + promo_filename,               // Full datafiles path
        working_directory + promo_filename,          // Working directory
        "docs/promo/" + promo_filename,              // Original location (fallback)
        working_directory + "docs/promo/" + promo_filename // Working directory + original path
    ];
    
    for (var i = 0; i < array_length(image_paths); i++) {
        var image_path = image_paths[i];
        show_debug_message("Trying menu background: " + image_path + " (exists: " + string(file_exists(image_path)) + ")");
        
        if (file_exists(image_path)) {
            try {
                background_image = sprite_add(image_path, 1, false, false, 0, 0);
                if (background_image != -1 && sprite_exists(background_image)) {
                    show_debug_message("Successfully loaded menu background: " + image_path);
                    return true;
                } else {
                    show_debug_message("sprite_add returned invalid sprite for: " + image_path);
                    if (background_image != -1) {
                        sprite_delete(background_image);
                        background_image = noone;
                    }
                }
            } catch (e) {
                show_debug_message("Failed to load menu background " + image_path + ": " + string(e));
            }
        }
    }
    
    show_debug_message("No menu background image could be loaded for: " + promo_filename);
    background_image = noone;
    return false;
}