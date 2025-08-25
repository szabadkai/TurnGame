// obj_CrewSelectUI Step Event

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Update input system
update_input_system();

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
    // Keyboard navigation variables
    if (!variable_instance_exists(id, "selected_crew_index")) {
        selected_crew_index = 0;
        selected_button = 0; // 0 = crew list, 1 = launch button
    }
    // Get available crew from crew system
    var available_crew = get_available_crew();
    
    // Get navigation input
    var nav = input_get_navigation();
    
    // Enhanced Keyboard Navigation (supports arrow keys and WASD)
    if (nav.up || nav.down || nav.left || nav.right) {
        if (selected_button == 0) {
            // Navigating crew list
            if (nav.up) {
                selected_crew_index = (selected_crew_index - 1 + array_length(available_crew)) % array_length(available_crew);
            } else if (nav.down) {
                if (selected_crew_index == array_length(available_crew) - 1) {
                    // Move to launch button
                    selected_button = 1;
                } else {
                    selected_crew_index = (selected_crew_index + 1) % array_length(available_crew);
                }
            } else if (nav.left) {
                // Navigate left through crew list (wrap around)
                selected_crew_index = (selected_crew_index - 1 + array_length(available_crew)) % array_length(available_crew);
            } else if (nav.right) {
                // Navigate right through crew list (wrap around)
                selected_crew_index = (selected_crew_index + 1) % array_length(available_crew);
            }
        } else {
            // On launch button
            if (nav.up) {
                selected_button = 0;
                selected_crew_index = array_length(available_crew) - 1;
            } else if (nav.left || nav.right) {
                // Left/Right on launch button goes back to crew list
                selected_button = 0;
                selected_crew_index = 0;
            }
            // Down from launch button does nothing (stay on launch button)
        }
    }
    
    // Toggle input (Space key only - only works on crew members)
    if (keyboard_check_pressed(vk_space)) {
        show_debug_message("Spacebar pressed! selected_button: " + string(selected_button));
        if (selected_button == 0) {
            // Toggle crew member selection
            var member_index = selected_crew_index;
            show_debug_message("Toggling crew member at index: " + string(member_index));
            
            // Find if member is already selected
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
                    show_debug_message("Added crew member " + string(member_index) + " to landing party");
                }
            } else {
                // Already selected, remove from landing party
                for (var k = selected_index; k < array_length(landing_party) - 1; k++) {
                    landing_party[k] = landing_party[k + 1];
                }
                array_resize(landing_party, array_length(landing_party) - 1);
                show_debug_message("Removed crew member " + string(member_index) + " from landing party");
            }
        }
        // Note: Spacebar on launch button does nothing - only Enter launches
    }
    
    // Submit input (Enter key) - Launches on button, toggles on crew
    if (keyboard_check_pressed(vk_enter)) {
        if (selected_button == 1) {
            // Launch button is selected
            show_debug_message("Enter key pressed on launch button - launching mission...");
            launch_mission();
        } 
    }
    
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
        var row_start_x = x + 5;
        var row_end_x = x + ui_width - 5;
        
        // Click anywhere on the crew member row to toggle selection
        if (mouse_check_button_pressed(mb_left) && gui_mouse_x >= row_start_x && gui_mouse_x <= row_end_x && gui_mouse_y >= member_y - 2 && gui_mouse_y <= member_y + 14) {
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