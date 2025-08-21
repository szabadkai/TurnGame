// Main Menu Manager - Step Event

// Handle menu appearance animation
if (menu_appear_timer < menu_appear_duration) {
    menu_appear_timer++;
}

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
        if (background_image != noone && sprite_exists(background_image)) {
            sprite_delete(background_image);
            background_image = noone;
        }
        */
    }
}

// Handle transitions
if (menu_state == MENUSTATE.TRANSITION) {
    transition_alpha += transition_speed * transition_direction;
    
    if (transition_direction == -1 && transition_alpha <= 0) {
        // Fade out complete, now change to new state
        transition_alpha = 0;
        transition_direction = 1;
        menu_state = previous_menu_state;
        update_current_options();
    } else if (transition_direction == 1 && transition_alpha >= 1) {
        // Fade in complete
        transition_alpha = 1;
        transition_direction = 1;
        menu_state = previous_menu_state;
    }
    return;
}

// Input handling
var input_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var input_down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var input_select = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
var input_back = keyboard_check_pressed(vk_escape);

// Navigation input
if (input_up) {
    selected_option--;
    if (selected_option < 0) {
        selected_option = array_length(current_options) - 1;
    }
    play_menu_navigate_sound();
}

if (input_down) {
    selected_option++;
    if (selected_option >= array_length(current_options)) {
        selected_option = 0;
    }
    play_menu_navigate_sound();
}

// State-specific input handling
switch (menu_state) {
    case MENUSTATE.MAIN:
        if (input_select) {
            handle_main_menu_selection();
        }
        break;
        
    case MENUSTATE.SETTINGS:
        if (input_select) {
            handle_settings_selection();
        } else if (input_back) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
        
    case MENUSTATE.SETTINGS_AUDIO:
        handle_audio_settings_input(input_select, input_back);
        break;
        
    case MENUSTATE.SETTINGS_GRAPHICS:
        handle_graphics_settings_input(input_select, input_back);
        break;
        
    case MENUSTATE.SETTINGS_CONTROLS:
        handle_controls_settings_input(input_select, input_back);
        break;
        
    case MENUSTATE.SETTINGS_GAMEPLAY:
        handle_gameplay_settings_input(input_select, input_back);
        break;
        
        
    case MENUSTATE.SAVE_LOAD:
        handle_save_load_input(input_select, input_back);
        break;
        
    case MENUSTATE.QUIT_CONFIRM:
        if (input_select) {
            if (selected_option == 0) {
                game_end();
            } else {
                change_menu_state(MENUSTATE.MAIN);
            }
        } else if (input_back) {
            change_menu_state(MENUSTATE.MAIN);
        }
        break;
}