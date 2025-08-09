// Only process input when visible
if (visible) {
    // Refresh player list to handle any destroyed players
    refresh_player_list();
    
    // ESC key handling is now managed by obj_UIManager
    
    // Handle player cycling with arrow keys
    if (array_length(player_list) > 1) {
        // Cycle to next player (right arrow)
        if (keyboard_check_pressed(vk_right)) {
            current_player_index = (current_player_index + 1) % array_length(player_list);
            player_instance = player_list[current_player_index];
        }
        
        // Cycle to previous player (left arrow)  
        if (keyboard_check_pressed(vk_left)) {
            current_player_index = (current_player_index - 1 + array_length(player_list)) % array_length(player_list);
            player_instance = player_list[current_player_index];
        }
    }
    
    // Safety check: if current player is destroyed, close details or switch to valid player
    if (array_length(player_list) == 0) {
        visible = false;
    } else if (!instance_exists(player_instance) || current_player_index >= array_length(player_list)) {
        current_player_index = 0;
        player_instance = player_list[current_player_index];
    }
}