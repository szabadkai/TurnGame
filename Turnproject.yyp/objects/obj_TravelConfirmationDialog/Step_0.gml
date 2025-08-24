// obj_TravelConfirmationDialog Step Event
// Handle dialog animation, input, and button interactions

// Update fade animation
dialog_alpha = lerp(dialog_alpha, dialog_target_alpha, fade_speed);

// Hide dialog when fully faded
if (dialog_target_alpha == 0 && dialog_alpha < 0.01) {
    dialog_visible = false;
    dialog_alpha = 0;
    system_info = {};
    pending_travel_room = -1;
    pending_system_id = "";
    pending_target_scene = "";
}

// Only process input if dialog is visible and sufficiently faded in
if (dialog_visible && dialog_alpha > 0.5) {
    
    // Update button hover states
    confirm_button_hover = is_mouse_over_confirm_button();
    cancel_button_hover = is_mouse_over_cancel_button();
    
    // Handle mouse clicks
    if (mouse_check_button_pressed(mb_left)) {
        if (dialog_state == "CONFIRMATION") {
            if (confirm_button_hover) {
                dialog_state = "LANDING_PARTY";
            } else if (cancel_button_hover) {
                cancel_travel();
            }
        } else if (dialog_state == "LANDING_PARTY") {
            // Handle landing party selection clicks
            var list_y = dialog_y + dialog_padding + 30;
            for (var i = 0; i < array_length(global.crew); i++) {
                var member_y = list_y + (i * 20);
                var check_x = dialog_x + dialog_padding;
                if (mouse_x >= check_x && mouse_x <= check_x + 12 && mouse_y >= member_y && mouse_y <= member_y + 12) {
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
            var button_y = dialog_y + dialog_height - 40;
            var launch_button_x = dialog_x + dialog_width/2 - button_width/2;
            if (mouse_x >= launch_button_x && mouse_x <= launch_button_x + button_width && mouse_y >= button_y && mouse_y <= button_y + button_height) {
                global.landing_party = landing_party;
                confirm_travel();
            }
        }
        // Click outside dialog cancels
        else if (mouse_x < dialog_x || mouse_x > dialog_x + dialog_width ||
                 mouse_y < dialog_y || mouse_y > dialog_y + dialog_height) {
            cancel_travel();
        }
    }
    
    // Handle keyboard shortcuts
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Y"))) {
        confirm_travel();
    }
    
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("N"))) {
        cancel_travel();
    }
}