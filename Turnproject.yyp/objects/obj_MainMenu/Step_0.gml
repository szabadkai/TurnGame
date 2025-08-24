// Main Menu Manager - Step Event

// Handle background fade transition (much longer duration now)
if (show_promo_background && background_fade_timer < background_fade_duration) {
    background_fade_timer++;
    
    // After a very long duration, optionally switch to semi-transparent backdrop
    // But now we keep the promo image for 30 seconds instead of 3
    if (background_fade_timer >= background_fade_duration) {
        // Option 1: Keep promo background forever (comment out the fade)
        // Option 2: Eventually fade to semi-transparent (uncomment lines below)
        /*
        show_promo_background = false;
        // Clean up background image
        if (background_image != noone && background_image != -1) {
            sprite_delete(background_image);
            background_image = noone;
        }
        */
    }
}

// Use base menu step handling
if (handle_base_menu_step()) {
    return; // Skip input handling during transitions
}

// Use base menu navigation
var inputs = handle_base_menu_navigation();

// State-specific input handling
switch (menu_state) {
    case MENUSTATE.MAIN:
        if (inputs.select) {
            handle_main_menu_selection_original();
        }
        break;
        
    case MENUSTATE.SETTINGS:
        if (inputs.select) {
            handle_settings_selection();
        } else if (inputs.cancel) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
        
    case MENUSTATE.SETTINGS_AUDIO:
        handle_audio_settings_input(inputs.select, inputs.cancel);
        break;
        
    case MENUSTATE.SETTINGS_GRAPHICS:
        handle_graphics_settings_input(inputs.select, inputs.cancel);
        break;
        
    case MENUSTATE.SETTINGS_CONTROLS:
        handle_controls_settings_input(inputs.select, inputs.cancel);
        break;
        
    case MENUSTATE.SETTINGS_GAMEPLAY:
        handle_gameplay_settings_input(inputs.select, inputs.cancel);
        break;
        
    case MENUSTATE.SAVE_LOAD:
        handle_save_load_input(inputs.select, inputs.cancel);
        break;
        
    case MENUSTATE.QUIT_CONFIRM:
        if (inputs.select) {
            if (selected_option == 0) {
                game_end();
            } else {
                change_menu_state(MENUSTATE.MAIN);
            }
        } else if (inputs.cancel) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
}