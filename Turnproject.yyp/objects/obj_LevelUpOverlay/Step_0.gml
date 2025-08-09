// Only process input when visible
if (!visible || !instance_exists(player_instance)) {
    exit;
}

// Handle mouse clicks on buttons
if (mouse_check_button_pressed(mb_left)) {
    var mouse_gui_x = device_mouse_x_to_gui(0);
    var mouse_gui_y = device_mouse_y_to_gui(0);
    
    for (var i = 0; i < array_length(buttons); i++) {
        var btn = buttons[i];
        
        if (mouse_gui_x >= btn.x && mouse_gui_x <= btn.x + btn.w &&
            mouse_gui_y >= btn.y && mouse_gui_y <= btn.y + btn.h) {
            
            if (btn.type == "plus" && asi_points_remaining > 0) {
                var current_value = variable_struct_get(asi_selections, btn.ability);
                var player_current = variable_instance_get(player_instance, btn.ability);
                
                // Can't exceed 20 total or +2 increase per ASI
                if (current_value < 2 && (player_current + current_value) < 20) {
                    variable_struct_set(asi_selections, btn.ability, current_value + 1);
                    asi_points_remaining--;
                }
            }
            else if (btn.type == "minus") {
                var current_value = variable_struct_get(asi_selections, btn.ability);
                if (current_value > 0) {
                    variable_struct_set(asi_selections, btn.ability, current_value - 1);
                    asi_points_remaining++;
                }
            }
            else if (btn.type == "confirm" && asi_points_remaining == 0) {
                apply_asi_improvements();
            }
            
            break;
        }
    }
}

// ESC key handling is now managed by obj_UIManager
// (Player can forfeit by closing the overlay)