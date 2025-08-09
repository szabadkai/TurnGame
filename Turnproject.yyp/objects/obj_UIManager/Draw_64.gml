// UI Manager - Input Handling
if (keyboard_check_pressed(vk_escape)) {
    // Close current UI
    close_all_ui();
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