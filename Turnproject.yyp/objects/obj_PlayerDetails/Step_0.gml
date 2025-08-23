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
    
    // Handle weapon cycling button clicks
    if (mouse_check_button_pressed(mb_left) && instance_exists(player_instance)) {
        var mouse_gui_x = device_mouse_x_to_gui(0);
        var mouse_gui_y = device_mouse_y_to_gui(0);
        
        // Check if buttons exist (they're created in Draw event)
        if (variable_instance_exists(id, "prev_weapon_button") && variable_instance_exists(id, "next_weapon_button")) {
            
            // Previous weapon button
            if (mouse_gui_x >= prev_weapon_button.x && mouse_gui_x <= prev_weapon_button.x + prev_weapon_button.w &&
                mouse_gui_y >= prev_weapon_button.y && mouse_gui_y <= prev_weapon_button.y + prev_weapon_button.h) {
                cycle_weapon(player_instance, -1);
            }
            
            // Next weapon button
            if (mouse_gui_x >= next_weapon_button.x && mouse_gui_x <= next_weapon_button.x + next_weapon_button.w &&
                mouse_gui_y >= next_weapon_button.y && mouse_gui_y <= next_weapon_button.y + next_weapon_button.h) {
                cycle_weapon(player_instance, 1);
            }
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

// Function to cycle through player weapons
function cycle_weapon(player, direction) {
    if (!instance_exists(player)) return;
    
    // Only cycle through player weapons (IDs 0-10), exclude enemy weapons (11-15)
    var max_player_weapons = 11;
    
    if (direction > 0) {
        // Next weapon
        player.equipped_weapon_id = (player.equipped_weapon_id + 1) % max_player_weapons;
    } else {
        // Previous weapon  
        player.equipped_weapon_id = (player.equipped_weapon_id - 1 + max_player_weapons) % max_player_weapons;
    }
    
    // Update combat stats with new weapon
    with(player) {
        update_combat_stats();
    }
    
    // Log weapon change
    scr_log(player.character_name + " equipped: " + player.weapon_name);
}
