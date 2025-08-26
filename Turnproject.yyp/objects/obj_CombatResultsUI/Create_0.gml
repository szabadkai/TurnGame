// obj_CombatResultsUI Create Event
// Initialize combat results overlay

// Combat result state
combat_result = ""; // "victory" or "defeat"
result_message = "";
result_details = "";
xp_awarded = 0;

// UI state
ui_visible = false;
ui_alpha = 0;
target_alpha = 0;
fade_speed = 0.05;

// UI layout - use GUI coordinates for proper centering
ui_x = display_get_gui_width() / 2;
ui_y = display_get_gui_height() / 2;
ui_width = 400;
ui_height = 300;

// Button properties
button_width = 200;
button_height = 50;
button_x = ui_x - (button_width / 2);
button_y = ui_y + 80;

button_hover = false;
button_color = c_gray;
button_hover_color = c_white;
button_text_color = c_black;

// Animation
bounce_timer = 0;
bounce_scale = 1.0;

show_debug_message("CombatResultsUI initialized");

// Show victory results
function show_victory_results(xp_gain = 0) {
    combat_result = "victory";
    result_message = "VICTORY!";
    result_details = "All enemies have been defeated!";
    xp_awarded = xp_gain;
    
    ui_visible = true;
    target_alpha = 1.0;
    bounce_timer = 0;
    
    show_debug_message("Showing victory results with " + string(xp_gain) + " XP");
}

// Show defeat results
function show_defeat_results() {
    combat_result = "defeat";
    result_message = "DEFEAT";
    result_details = "All party members have fallen...";
    xp_awarded = 0;
    
    ui_visible = true;
    target_alpha = 1.0;
    bounce_timer = 0;
    
    show_debug_message("Showing defeat results");
}

// Handle return to star map button click
function handle_return_button() {
    show_debug_message("Return to star map button clicked");
    
    // Hide UI first
    target_alpha = 0;
    ui_visible = false;
    
    // Save progress before returning to star map
    var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
    try {
        save_game_to_slot(slot_to_use, true);
    } catch (e) { /* ignore */ }
    
    // Initialize star map system if needed
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    // Set flag to load star map state when we get there
    global.should_load_star_map_state = true;
    
    // Mark that we want to return to star map after current room operations
    global.return_to_star_map_after_combat = false; // Reset this flag
    
    // Return to star map
    show_debug_message("Transitioning to star map with preserved progress");
    scr_nav_go(GameState.STARMAP, undefined);
}

// Check if mouse is over return button
function is_mouse_over_button() {
    return (mouse_x >= button_x && mouse_x <= button_x + button_width &&
            mouse_y >= button_y && mouse_y <= button_y + button_height);
}
