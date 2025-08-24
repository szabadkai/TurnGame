// obj_LandingPartyUI Step Event

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
    // Handle landing party selection clicks
    var list_y = y + 30;
    for (var i = 0; i < array_length(global.crew); i++) {
        var member_y = list_y + (i * 20);
        var check_x = x + 10;
        if (mouse_check_button_pressed(mb_left) && mouse_x >= check_x && mouse_x <= check_x + 12 && mouse_y >= member_y && mouse_y <= member_y + 12) {
            var member_index = i;
            var selected_index = array_indexOf(landing_party, member_index);
            if (selected_index == -1) {
                if (array_length(landing_party) < max_landing_party_size) {
                    array_push(landing_party, member_index);
                }
            } else {
                array_delete(landing_party, selected_index, 1);
            }
        }
    }

    // Handle launch button click
    var button_y = y + 180;
    var launch_button_x = x + 110;
    if (mouse_check_button_pressed(mb_left) && mouse_x >= launch_button_x && mouse_x <= launch_button_x + 80 && mouse_y >= button_y && mouse_y <= button_y + 30) {
        launch_mission();
    }
}