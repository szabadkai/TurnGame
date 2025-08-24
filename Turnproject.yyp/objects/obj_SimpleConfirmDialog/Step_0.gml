// Simple Confirmation Dialog Step Event

// Update alpha
show_alpha = lerp(show_alpha, target_alpha, 0.2);

// Hide when fully faded
if (target_alpha == 0 && show_alpha < 0.01) {
    show_visible = false;
    show_alpha = 0;
}

// Handle input if visible
if (show_visible && show_alpha > 0.5) {
    
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Y"))) {
        show_debug_message("Simple dialog: CONFIRMED");
        hide_confirmation();
        if (confirm_callback != -1) {
            confirm_callback();
        }
    }
    
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("N"))) {
        show_debug_message("Simple dialog: CANCELLED");
        hide_confirmation();
        if (cancel_callback != -1) {
            cancel_callback();
        }
    }
    
    if (mouse_check_button_pressed(mb_left)) {
        show_debug_message("Simple dialog: Mouse clicked - cancelling");
        hide_confirmation();
        if (cancel_callback != -1) {
            cancel_callback();
        }
    }
}