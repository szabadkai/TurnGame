// UI Manager - Input Handling

// Debug: Test if this object is even running
if (keyboard_check_pressed(ord("T"))) {
    if (variable_global_exists("combat_log")) {
        global.combat_log("UI Manager: TEST - UIManager is running!");
    }
}

if (keyboard_check_pressed(vk_escape)) {
    // Close current UI
    close_all_ui();
}

// Handle 'I' key - open player details or level-up overlay
if (keyboard_check_pressed(ord("I"))) {

    global.combat_log("UI Manager: 'I' key pressed");
    
    // Don't open new UI if something is already open
    if (ui_state != "none") {
        if (variable_global_exists("combat_log")) {
            global.combat_log("UI Manager: UI already open, ignoring 'I' key");
        }
        exit;
    }
    
    // Get the current active player (or first player if none active)
    var target_player = get_current_active_player();
    

    
    global.combat_log("UI Manager: Target player - " + target_player.character_name + " (level " + string(target_player.level) + ")");

    // Check if player has unused ASI first
    if (can_increase_ability_score(target_player)) {
        show_level_up_overlay(target_player);
    } else {
        show_player_details(target_player);
    }
}