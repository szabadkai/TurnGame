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
        if (confirm_button_hover) {
            confirm_travel();
        } else if (cancel_button_hover) {
            cancel_travel();
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