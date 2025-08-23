// Menu settings input handling functions

// Handle audio settings input
function handle_audio_settings_input(input_select, input_back) {
    var input_left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
    var input_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
    
    if (input_left || input_right) {
        var change = input_right ? 0.1 : -0.1;
        
        switch (selected_option) {
            case AUDIO_OPTION.MASTER_VOLUME:
                global.game_settings.master_volume = clamp(global.game_settings.master_volume + change, 0, 1);
                audio_set_master_gain(0, global.game_settings.master_volume);
                break;
            case AUDIO_OPTION.SFX_VOLUME:
                global.game_settings.sfx_volume = clamp(global.game_settings.sfx_volume + change, 0, 1);
                break;
            case AUDIO_OPTION.MUSIC_VOLUME:
                global.game_settings.music_volume = clamp(global.game_settings.music_volume + change, 0, 1);
                break;
        }
        save_settings();
    }
    
    if (input_select && selected_option == AUDIO_OPTION.BACK) {
        change_menu_state(MENUSTATE.SETTINGS);
    }
    
    if (input_back) {
        change_menu_state(MENUSTATE.SETTINGS);
    }
}

// Handle graphics settings input
function handle_graphics_settings_input(input_select, input_back) {
    var input_left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
    var input_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
    
    if (input_left || input_right || input_select) {
        switch (selected_option) {
            case GRAPHICS_OPTION.FULLSCREEN:
                if (input_left || input_right || input_select) {
                    global.game_settings.fullscreen = !global.game_settings.fullscreen;
                    window_set_fullscreen(global.game_settings.fullscreen);
                }
                break;
            case GRAPHICS_OPTION.BACK:
                if (input_select) {
                    change_menu_state(MENUSTATE.SETTINGS);
                }
                break;
        }
        save_settings();
    }
    
    if (input_back) {
        change_menu_state(MENUSTATE.SETTINGS);
    }
}

// Handle controls settings input
function handle_controls_settings_input(input_select, input_back) {
    if (input_select) {
        switch (selected_option) {
            case CONTROLS_OPTION.MOVE_UP:
            case CONTROLS_OPTION.MOVE_DOWN:
            case CONTROLS_OPTION.MOVE_LEFT:
            case CONTROLS_OPTION.MOVE_RIGHT:
            case CONTROLS_OPTION.ATTACK:
            case CONTROLS_OPTION.DETAILS:
                // Start key binding mode (for future implementation)
                show_debug_message("Key binding not implemented yet");
                break;
            case CONTROLS_OPTION.BACK:
                change_menu_state(MENUSTATE.SETTINGS);
                break;
        }
    }
    
    if (input_back) {
        change_menu_state(MENUSTATE.SETTINGS);
    }
}

// Handle gameplay settings input
function handle_gameplay_settings_input(input_select, input_back) {
    var input_left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
    var input_right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
    
    if (input_left || input_right || input_select) {
        switch (selected_option) {
            case GAMEPLAY_OPTION.COMBAT_SPEED:
                if (input_left || input_right) {
                    var change = input_right ? 1 : -1;
                    global.game_settings.combat_speed = clamp(global.game_settings.combat_speed + change, 0, 2);
                }
                break;
            case GAMEPLAY_OPTION.AUTO_SAVE:
                if (input_left || input_right || input_select) {
                    global.game_settings.auto_save = !global.game_settings.auto_save;
                }
                break;
            case GAMEPLAY_OPTION.DIFFICULTY:
                if (input_left || input_right) {
                    var change = input_right ? 1 : -1;
                    global.game_settings.difficulty = clamp(global.game_settings.difficulty + change, 0, 2);
                }
                break;
            case GAMEPLAY_OPTION.BACK:
                if (input_select) {
                    change_menu_state(MENUSTATE.SETTINGS);
                }
                break;
        }
        save_settings();
    }
    
    if (input_back) {
        change_menu_state(MENUSTATE.SETTINGS);
    }
}


// Handle save/load input
function handle_save_load_input(input_select, input_back) {
    if (input_select) {
        if (selected_option < 3) {
            var slot_index = selected_option + 1; // Convert 0-2 to slots 1-3
            if (save_slot_exists(slot_index)) {
                show_debug_message("Loading game from slot " + string(slot_index));
                // Set this as the active save slot for this playthrough
                set_active_save_slot(slot_index);
                // Use the proper save loading function from save_system.gml
                load_game_from_slot_data(slot_index);
            } else {
                show_debug_message("Save slot " + string(slot_index) + " is empty");
                play_menu_error_sound();
            }
        } else {
            // Back option
            change_menu_state(MENUSTATE.MAIN);
        }
    }
    
    // Delete key (X or Delete) to delete save slots - double press for confirmation
    if ((keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_delete)) && selected_option < 3) {
        var slot_index = selected_option + 1; // Convert 0-2 to slots 1-3
        if (save_slot_exists(slot_index)) {
            // Simple double-press confirmation
            if (!variable_global_exists("delete_confirm_slot") || global.delete_confirm_slot != slot_index) {
                // First press - set confirmation
                global.delete_confirm_slot = slot_index;
                global.delete_confirm_time = get_timer();
                show_debug_message("Press X again to confirm deletion of slot " + string(slot_index));
                play_menu_navigate_sound();
            } else {
                // Second press within 3 seconds - confirm delete
                var time_diff = (get_timer() - global.delete_confirm_time) / 1000000;
                if (time_diff < 3.0) {
                    show_debug_message("Confirmed: Deleting save slot " + string(slot_index));
                    delete_save_slot(slot_index);
                    play_menu_select_sound();
                    global.delete_confirm_slot = -1; // Reset confirmation
                } else {
                    // Too long, restart confirmation
                    global.delete_confirm_slot = slot_index;
                    global.delete_confirm_time = get_timer();
                    show_debug_message("Press X again to confirm deletion of slot " + string(slot_index));
                    play_menu_navigate_sound();
                }
            }
        } else {
            play_menu_error_sound();
        }
    }
    
    // Reset delete confirmation if selecting different option
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)) {
        if (variable_global_exists("delete_confirm_slot")) {
            global.delete_confirm_slot = -1;
        }
    }
    
    if (input_back) {
        change_menu_state(MENUSTATE.MAIN);
    }
}

// Save settings to file
function save_settings() {
    var settings_file = "game_settings.ini";
    
    ini_open(settings_file);
    
    ini_write_real("audio", "master_volume", global.game_settings.master_volume);
    ini_write_real("audio", "sfx_volume", global.game_settings.sfx_volume);
    ini_write_real("audio", "music_volume", global.game_settings.music_volume);
    
    ini_write_real("graphics", "fullscreen", global.game_settings.fullscreen);
    
    ini_write_real("gameplay", "combat_speed", global.game_settings.combat_speed);
    ini_write_real("gameplay", "auto_save", global.game_settings.auto_save);
    ini_write_real("gameplay", "difficulty", global.game_settings.difficulty);
    
    ini_write_real("controls", "key_up", global.game_settings.key_up);
    ini_write_real("controls", "key_down", global.game_settings.key_down);
    ini_write_real("controls", "key_left", global.game_settings.key_left);
    ini_write_real("controls", "key_right", global.game_settings.key_right);
    ini_write_real("controls", "key_attack", global.game_settings.key_attack);
    ini_write_real("controls", "key_details", global.game_settings.key_details);
    
    ini_close();
}

// Load settings from file
function load_settings() {
    var settings_file = "game_settings.ini";
    
    if (file_exists(settings_file)) {
        ini_open(settings_file);
        
        global.game_settings.master_volume = ini_read_real("audio", "master_volume", 1.0);
        global.game_settings.sfx_volume = ini_read_real("audio", "sfx_volume", 1.0);
        global.game_settings.music_volume = ini_read_real("audio", "music_volume", 1.0);
        
        global.game_settings.fullscreen = ini_read_real("graphics", "fullscreen", false);
        
        global.game_settings.combat_speed = ini_read_real("gameplay", "combat_speed", 1.0);
        global.game_settings.auto_save = ini_read_real("gameplay", "auto_save", true);
        global.game_settings.difficulty = ini_read_real("gameplay", "difficulty", 1);
        
        global.game_settings.key_up = ini_read_real("controls", "key_up", vk_up);
        global.game_settings.key_down = ini_read_real("controls", "key_down", vk_down);
        global.game_settings.key_left = ini_read_real("controls", "key_left", vk_left);
        global.game_settings.key_right = ini_read_real("controls", "key_right", vk_right);
        global.game_settings.key_attack = ini_read_real("controls", "key_attack", vk_space);
        global.game_settings.key_details = ini_read_real("controls", "key_details", ord("I"));
        
        ini_close();
        
        // Apply loaded settings
        audio_set_master_gain(0, global.game_settings.master_volume);
        window_set_fullscreen(global.game_settings.fullscreen);
    }
}

// Load game from save slot
// Removed stub function - now using proper load_game_from_slot_data from save_system.gml

// Additional drawing functions for settings menus

function draw_save_load_info() {
    // Draw save file details
    if (selected_option < 3) {
        // Additional save info could be drawn here
    }
}

function draw_settings_values() {
    // Any additional settings visualization could be drawn here
}