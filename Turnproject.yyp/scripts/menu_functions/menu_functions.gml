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
                return !save_slot_exists(option_index);
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
                case GRAPHICS_OPTION.ZOOM_LEVEL:
                    return base_text + ": " + string(global.game_settings.zoom_level) + "x";
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
                if (save_slot_exists(option_index)) {
                    var save_info = get_save_slot_info(option_index);
                    return base_text + " - " + save_info;
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
        case MENUSTATE.SETTINGS_AUDIO:
        case MENUSTATE.SETTINGS_GRAPHICS:
        case MENUSTATE.SETTINGS_GAMEPLAY:
            return "↑↓ Navigate • ←→ Change • Enter Select • Esc Back";
        default:
            return base_instructions + " • Esc Back";
    }
}

// Handle main menu selection
function handle_main_menu_selection() {
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
        case MAINMENU_OPTION.SETTINGS:
            play_menu_select_sound();
            change_menu_state(MENUSTATE.SETTINGS);
            break;
        case MAINMENU_OPTION.SCENE_GALLERY:
            play_menu_select_sound();
            // Launch scene selector directly by going to dialog room and starting selection
            start_scene_selection();
            room_goto(Room_Dialog);
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
    show_debug_message("Starting new game...");
    room_goto(global.gameplay_room);
}

// Check if save files exist
function has_save_files() {
    for (var i = 0; i < 3; i++) {
        if (save_slot_exists(i)) {
            return true;
        }
    }
    return false;
}

// Check if specific save slot exists
function save_slot_exists(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    return file_exists(save_file);
}

// Get save slot info string
function get_save_slot_info(slot_index) {
    var save_file = "save_slot_" + string(slot_index) + ".sav";
    if (file_exists(save_file)) {
        // For now, just return a placeholder
        // In a full implementation, you'd load the save file and extract info
        return "Level X - Location Y";
    }
    return "Empty";
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