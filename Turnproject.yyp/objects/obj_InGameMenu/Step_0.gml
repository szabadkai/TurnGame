// In-Game Menu Manager - Step Event

// Use base menu step handling
if (handle_base_menu_step()) {
    return; // Skip input handling during transitions
}

// Use base menu navigation
var inputs = handle_base_menu_navigation();

// If we're in main menu and ESC was pressed, mark it as consumed to prevent UIManager from processing it
if (menu_state == MENUSTATE.MAIN && inputs.back) {
    // Consume the ESC key by clearing the keyboard buffer for this key
    keyboard_clear(vk_escape);
}

// State-specific input handling
switch (menu_state) {
    case MENUSTATE.MAIN:
        if (inputs.select) {
            handle_in_game_menu_selection();
        } else if (inputs.back) {
            // ESC in main in-game menu = Resume Game
            play_menu_select_sound();
            close_menu();
        }
        break;
        
    case MENUSTATE.SETTINGS:
        if (inputs.select) {
            handle_settings_selection();
        } else if (inputs.back) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
        
    case MENUSTATE.SETTINGS_AUDIO:
        handle_audio_settings_input(inputs.select, inputs.back);
        break;
        
    case MENUSTATE.SETTINGS_GRAPHICS:
        handle_graphics_settings_input(inputs.select, inputs.back);
        break;
        
    case MENUSTATE.SETTINGS_CONTROLS:
        handle_controls_settings_input(inputs.select, inputs.back);
        break;
        
    case MENUSTATE.SETTINGS_GAMEPLAY:
        handle_gameplay_settings_input(inputs.select, inputs.back);
        break;
        
    case MENUSTATE.SAVE_LOAD:
        handle_save_load_input(inputs.select, inputs.back);
        break;
        
    case MENUSTATE.QUIT_CONFIRM:
        if (inputs.select) {
            if (selected_option == 0) {
                // Yes - Return to main menu
                room_goto(Room_MainMenu);
            } else {
                // No - Back to in-game menu
                change_menu_state(MENUSTATE.MAIN);
            }
        } else if (inputs.back) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
}