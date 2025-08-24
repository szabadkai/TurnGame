// obj_CrewSelectUI Step Event

// Update fade animation
ui_alpha = lerp(ui_alpha, ui_target_alpha, fade_speed);

// Hide UI when fully faded
if (ui_target_alpha == 0 && ui_alpha < 0.01) {
    ui_visible = false;
    ui_alpha = 0;
    instance_destroy(); // Remove the UI object when it's hidden
}

// Only process input if UI is visible
if (ui_visible && ui_alpha > 0.5) {
    // Get available crew from crew system
    var available_crew = get_available_crew();
    
    // Use GUI mouse coordinates since UI is drawn in Draw_64
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);
    
    // Debug mouse coordinates on click
    if (mouse_check_button_pressed(mb_left)) {
        show_debug_message("Mouse clicked at GUI: " + string(gui_mouse_x) + ", " + string(gui_mouse_y));
        show_debug_message("UI positioned at: " + string(x) + ", " + string(y));
    }

    // Handle landing party selection clicks
    var list_y = y + 55;
    for (var i = 0; i < array_length(available_crew); i++) {
        var member_y = list_y + (i * 20);
        var check_x = x + 10;
        
        // Debug checkbox bounds on click
        if (mouse_check_button_pressed(mb_left)) {
            show_debug_message("Checkbox " + string(i) + " bounds: X[" + string(check_x) + "-" + string(check_x + 12) + "] Y[" + string(member_y) + "-" + string(member_y + 12) + "]");
        }
        
        if (mouse_check_button_pressed(mb_left) && gui_mouse_x >= check_x && gui_mouse_x <= check_x + 12 && gui_mouse_y >= member_y && gui_mouse_y <= member_y + 12) {
            var member_index = i;
            show_debug_message("Checkbox clicked for crew member " + string(member_index));
            
            // Find if member is already selected (custom implementation)
            var selected_index = -1;
            for (var k = 0; k < array_length(landing_party); k++) {
                if (landing_party[k] == member_index) {
                    selected_index = k;
                    break;
                }
            }
            
            if (selected_index == -1) {
                // Not selected, add to landing party
                if (array_length(landing_party) < max_landing_party_size) {
                    landing_party[array_length(landing_party)] = member_index;
                }
            } else {
                // Already selected, remove from landing party
                for (var k = selected_index; k < array_length(landing_party) - 1; k++) {
                    landing_party[k] = landing_party[k + 1];
                }
                array_resize(landing_party, array_length(landing_party) - 1);
            }
        }
    }

    // Handle launch button click
    var button_y = y + ui_height - 50;
    var button_width = 120;
    var launch_button_x = x + ui_width/2 - button_width/2;
    
    if (mouse_check_button_pressed(mb_left) && gui_mouse_x >= launch_button_x && gui_mouse_x <= launch_button_x + button_width && gui_mouse_y >= button_y && gui_mouse_y <= button_y + 35) {
        show_debug_message("Launch button clicked!");
        launch_mission();
    }
}