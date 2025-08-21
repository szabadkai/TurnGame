// Menu Base System - Shared functions for all menu types
// Provides common functionality for main menu, in-game menu, etc.

// Menu context types
enum MENU_CONTEXT {
    MAIN_MENU,
    IN_GAME_MENU
}

// Initialize base menu variables (call in Create event)
function init_base_menu(context, options_array) {
    // Store menu context
    menu_context = context;
    
    // Menu state variables
    menu_state = MENUSTATE.MAIN;
    previous_menu_state = MENUSTATE.MAIN;
    selected_option = 0;
    transition_alpha = 0;
    transition_speed = 0.05;
    transition_direction = 1; // 1 = fade in, -1 = fade out
    
    // Set main options based on context
    main_menu_options = options_array;
    
    // Common submenu options (reused across contexts)
    settings_options = [
        "Audio",
        "Graphics", 
        "Controls",
        "Gameplay",
        "Back"
    ];
    
    audio_options = [
        "Master Volume",
        "SFX Volume",
        "Music Volume",
        "Back"
    ];
    
    graphics_options = [
        "Fullscreen",
        "Zoom Level",
        "Back"
    ];
    
    controls_options = [
        "Move Up",
        "Move Down", 
        "Move Left",
        "Move Right",
        "Attack",
        "Player Details",
        "Back"
    ];
    
    gameplay_options = [
        "Combat Speed",
        "Auto Save",
        "Difficulty",
        "Back"
    ];
    
    // Current menu options reference
    current_options = main_menu_options;
    
    // Menu positioning
    menu_x = room_width / 2;
    menu_y = room_height / 2;
    option_spacing = 16;
    title_y_offset = -60;
    
    // Font and colors
    menu_font = Font1;
    title_color = c_white;
    selected_color = c_yellow;
    normal_color = c_ltgray;
    disabled_color = c_gray;
    
    // Menu animation variables
    menu_appear_timer = 0;
    menu_appear_duration = 30;
    
    // Save system variables
    save_slots = [];
    selected_save_slot = 0;
    check_save_slots();
}

// Common navigation input handling
function handle_base_menu_navigation() {
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
    
    return {
        up: input_up,
        down: input_down,
        select: input_select,
        back: input_back
    };
}

// Common step logic for menus
function handle_base_menu_step() {
    // Handle menu appearance animation
    if (menu_appear_timer < menu_appear_duration) {
        menu_appear_timer++;
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
        return true; // Skip other input handling during transitions
    }
    
    return false; // Continue with input handling
}

// Common drawing function
function draw_base_menu(show_background_image, background_image_sprite) {
    // Set font
    draw_set_font(menu_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // Calculate menu appearance progress
    var appear_progress = clamp(menu_appear_timer / menu_appear_duration, 0, 1);
    var alpha_mod = appear_progress;
    
    // Apply transition alpha if transitioning
    if (menu_state == MENUSTATE.TRANSITION) {
        alpha_mod *= transition_alpha;
    }
    
    // Draw background
    if (show_background_image && background_image_sprite != noone && sprite_exists(background_image_sprite)) {
        // Draw promo background image (for main menu)
        draw_set_alpha(1.0 * alpha_mod);
        draw_set_color(c_white);
        
        // Scale image to fit screen while maintaining aspect ratio
        var screen_w = display_get_gui_width();
        var screen_h = display_get_gui_height();
        var img_w = sprite_get_width(background_image_sprite);
        var img_h = sprite_get_height(background_image_sprite);
        
        var scale_x = screen_w / img_w;
        var scale_y = screen_h / img_h;
        var scale = max(scale_x, scale_y); // Use larger scale to fill screen
        
        var draw_w = img_w * scale;
        var draw_h = img_h * scale;
        var draw_x = (screen_w - draw_w) / 2;
        var draw_y = (screen_h - draw_h) / 2;
        
        draw_sprite_ext(background_image_sprite, 0, draw_x, draw_y, scale, scale, 0, c_white, alpha_mod);
        
        // Add subtle dark overlay for better text readability
        draw_set_alpha(0.3 * alpha_mod);
        draw_set_color(c_black);
        draw_rectangle(0, 0, screen_w, screen_h, false);
    } else {
        // Draw semi-transparent black backdrop (for in-game menu or fallback)
        var overlay_alpha = (menu_context == MENU_CONTEXT.IN_GAME_MENU) ? 0.7 : 0.8;
        draw_set_alpha(overlay_alpha * alpha_mod);
        draw_set_color(c_black);
        draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    }
    
    // Draw title with effects
    draw_set_alpha(1.0 * alpha_mod);
    var title_text = get_menu_title();
    
    // Add title glow effect for main menu
    if (menu_state == MENUSTATE.MAIN) {
        // Draw title shadow
        draw_set_color(c_black);
        draw_text(menu_x + 2, menu_y + title_y_offset + 2, title_text);
        
        // Draw title with pulse effect
        var pulse = 0.8 + sin(current_time * 0.003) * 0.2;
        draw_set_color(merge_color(c_white, c_yellow, pulse));
    } else {
        draw_set_color(title_color);
    }
    
    draw_text(menu_x, menu_y + title_y_offset, title_text);
    
    // Draw menu options
    for (var i = 0; i < array_length(current_options); i++) {
        var option_y = menu_y + (i * option_spacing) - ((array_length(current_options) - 1) * option_spacing / 2);
        
        // Set color based on selection and availability
        var option_color = normal_color;
        var option_alpha = alpha_mod;
        
        if (i == selected_option) {
            option_color = selected_color;
            // Add subtle pulse animation for selected option
            var pulse = sin(current_time * 0.01) * 0.2 + 0.8;
            option_alpha *= pulse;
        }
        
        // Check if option should be disabled
        if (is_option_disabled(i)) {
            option_color = disabled_color;
            option_alpha *= 0.5;
        }
        
        draw_set_color(option_color);
        draw_set_alpha(option_alpha);
        
        var option_text = get_option_display_text(i);
        draw_text(menu_x, option_y, option_text);
    }
    
    // State-specific drawing
    switch (menu_state) {
        case MENUSTATE.SAVE_LOAD:
            draw_save_load_info();
            break;
            
        case MENUSTATE.SETTINGS_AUDIO:
        case MENUSTATE.SETTINGS_GRAPHICS:
        case MENUSTATE.SETTINGS_CONTROLS:
        case MENUSTATE.SETTINGS_GAMEPLAY:
            draw_settings_values();
            break;
    }
    
    // Draw instructions at bottom
    draw_set_alpha(0.7 * alpha_mod);
    draw_set_color(c_ltgray);
    draw_set_valign(fa_bottom);
    var instructions = get_instruction_text();
    draw_text(menu_x, display_get_gui_height() - 10, instructions);
    
    // Reset draw settings
    draw_set_alpha(1.0);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Context-aware option handling
function handle_main_menu_selection_base() {
    switch (menu_context) {
        case MENU_CONTEXT.MAIN_MENU:
            handle_main_menu_selection_original();
            break;
        case MENU_CONTEXT.IN_GAME_MENU:
            handle_in_game_menu_selection();
            break;
    }
}

// In-game menu specific option handling
function handle_in_game_menu_selection() {
    switch (selected_option) {
        case 0: // Resume Game
            play_menu_select_sound();
            close_menu();
            break;
        case 1: // Save Game
            if (has_save_files() || true) { // Allow saving even if no saves exist
                play_menu_select_sound();
                change_menu_state(MENUSTATE.SAVE_LOAD);
            } else {
                play_menu_error_sound();
            }
            break;
        case 2: // Load Game
            if (has_save_files()) {
                play_menu_select_sound();
                change_menu_state(MENUSTATE.SAVE_LOAD);
            } else {
                play_menu_error_sound();
            }
            break;
        case 3: // Settings
            play_menu_select_sound();
            change_menu_state(MENUSTATE.SETTINGS);
            break;
        case 4: // Main Menu
            play_menu_select_sound();
            change_menu_state(MENUSTATE.QUIT_CONFIRM); // Reuse quit confirm for "Return to Main Menu?"
            break;
    }
}

// Close menu function will be defined by individual menu instances

// Get menu title based on context and state
function get_menu_title_base() {
    switch (menu_state) {
        case MENUSTATE.MAIN:
            return (menu_context == MENU_CONTEXT.MAIN_MENU) ? "TURN PROJECT" : "GAME MENU";
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
            return (menu_context == MENU_CONTEXT.IN_GAME_MENU && selected_option < 3) ? "SAVE GAME" : "LOAD GAME";
        case MENUSTATE.QUIT_CONFIRM:
            return (menu_context == MENU_CONTEXT.IN_GAME_MENU) ? "RETURN TO MAIN MENU?" : "QUIT GAME?";
        default:
            return "MENU";
    }
}