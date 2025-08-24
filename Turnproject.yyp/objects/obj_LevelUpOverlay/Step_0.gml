// Only process input when visible
if (!visible || !instance_exists(player_instance)) {
    exit;
}

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Update input system
update_input_system();

// Initialize keyboard navigation variables
if (!variable_instance_exists(id, "selected_ability")) {
    selected_ability = 0; // 0-5 for abilities, 6 for confirm button
    keyboard_mode = false; // Track if using keyboard navigation
}

// Get navigation input
var nav = input_get_navigation();

// Keyboard Navigation
if (nav.up || nav.down || nav.left || nav.right) {
    keyboard_mode = true;
    
    if (nav.up) {
        selected_ability = (selected_ability - 1 + 7) % 7; // 7 total items (6 abilities + 1 confirm)
    } else if (nav.down) {
        selected_ability = (selected_ability + 1) % 7;
    }
}

// Handle keyboard actions
if (keyboard_mode && (nav.select || nav.toggle || input_check_pressed("navigate_left") || input_check_pressed("navigate_right"))) {
    var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"];
    
    if (selected_ability < 6) {
        // Operating on ability scores
        var ability = abilities[selected_ability];
        var current_value = variable_struct_get(asi_selections, ability);
        var player_current = variable_instance_get(player_instance, ability);
        
        if ((nav.select && nav.right) || input_check_pressed("navigate_right")) {
            // Increase ability (like + button)
            if (asi_points_remaining > 0 && current_value < 2 && (player_current + current_value) < 20) {
                variable_struct_set(asi_selections, ability, current_value + 1);
                asi_points_remaining--;
            }
        } else if ((nav.select && nav.left) || input_check_pressed("navigate_left")) {
            // Decrease ability (like - button)
            if (current_value > 0) {
                variable_struct_set(asi_selections, ability, current_value - 1);
                asi_points_remaining++;
            }
        } else if (nav.select || nav.toggle) {
            // Default action: increase ability with Space/Enter
            if (asi_points_remaining > 0 && current_value < 2 && (player_current + current_value) < 20) {
                variable_struct_set(asi_selections, ability, current_value + 1);
                asi_points_remaining--;
            }
        }
    } else {
        // Confirm button selected
        if ((nav.select || nav.toggle) && asi_points_remaining == 0) {
            apply_asi_improvements();
        }
    }
}

// Handle mouse clicks on buttons
if (mouse_check_button_pressed(mb_left)) {
    keyboard_mode = false; // Switch to mouse mode
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