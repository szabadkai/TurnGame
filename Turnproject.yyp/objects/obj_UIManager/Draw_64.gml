// UI Manager - Input Handling
if (keyboard_check_pressed(vk_escape)) {
    // Priority 1: If any UI is showing, close it
    if (ui_state != "none") {
        close_all_ui();
    } else {
        // Priority 2: If no UI is showing, create in-game menu
        var existing_menu = instance_find(obj_InGameMenu, 0);
        if (existing_menu == noone) {
            // No in-game menu exists, create one
            instance_create_layer(0, 0, "Instances", obj_InGameMenu);
        }
        // Note: If menu exists, it handles ESC itself via keyboard_clear()
    }
}

// Handle 'I' key - open player details or level-up overlay
if (keyboard_check_pressed(ord("I"))) {
    // Don't open new UI if something is already open
    if (ui_state != "none") {
        exit;
    }
    
    // Get the current active player (or first player if none active)
    var target_player = get_current_active_player();

    // Check if player needs ASI first
    if (target_player.needs_asi) {
        show_level_up_overlay(target_player);
    } else {
        show_player_details(target_player);
    }
}