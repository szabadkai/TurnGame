// Test Button Step Event

if (mouse_check_button_pressed(mb_left)) {
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    // Check if mouse clicked on our test button area
    if (mx >= 100 && mx <= 200 && my >= 100 && my <= 130) {
        show_debug_message("Test button clicked!");
        
        if (instance_exists(confirmation_dialog)) {
            show_debug_message("Showing test dialog");
            
            var test_data = {
                name: "Test System",
                type: "Test Type",
                faction: "Test Faction",
                threat: 3
            };
            
            confirmation_dialog.pending_system_id = "test_system";
            confirmation_dialog.pending_target_scene = "test_scene";
            confirmation_dialog.show_travel_confirmation(test_data, room);
        } else {
            show_debug_message("Dialog instance doesn't exist!");
        }
    }
}