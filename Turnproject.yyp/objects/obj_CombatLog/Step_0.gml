// Update log dimensions
update_log_dimensions();

// Check if mouse is over log area (use GUI coordinates)
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
mouse_over_log = point_in_rectangle(mx, my, log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5);


// Handle log state toggle (L key or click anywhere on log area)
var clicked_on_log = mouse_check_button_pressed(mb_left) && mouse_over_log;

// In nub state, clicking anywhere on the nub should expand
// In other states, clicking the collapse button should toggle
var should_toggle = false;

if (keyboard_check_pressed(ord("L"))) {
    should_toggle = true;
} else if (clicked_on_log) {
    if (log_state == LOG_STATE.NUB) {
        // Click anywhere on the nub to expand
        should_toggle = true;
    } else {
        // In full/oneline state, only click the collapse button
        var btn_x = log_x + log_width - collapse_button_size;
        var btn_y = log_y - 5;
        if (point_in_rectangle(mx, my, btn_x, btn_y, btn_x + collapse_button_size, btn_y + collapse_button_size)) {
            should_toggle = true;
        }
    }
}

if (should_toggle) {
    
    // Cycle through states
    switch(log_state) {
        case LOG_STATE.FULL:
            log_state = LOG_STATE.ONELINE;
            break;
        case LOG_STATE.ONELINE:
            log_state = LOG_STATE.NUB;
            break;
        case LOG_STATE.NUB:
            log_state = LOG_STATE.FULL;
            break;
    }
    
    // Reset scroll when changing states
    scroll_offset = 0;
}

// Handle scrolling (only in FULL state)
if (log_state == LOG_STATE.FULL) {
    var wheel_up = mouse_wheel_up();
    var wheel_down = mouse_wheel_down();
    
    // Allow scrolling when mouse is over log OR when arrow keys are pressed
    if ((wheel_up && mouse_over_log) || keyboard_check_pressed(vk_up)) {
        scroll_offset = max(0, scroll_offset - scroll_speed);
    }
    
    if ((wheel_down && mouse_over_log) || keyboard_check_pressed(vk_down)) {
        var max_scroll = max(0, array_length(combat_messages) - max_visible_messages);
        scroll_offset = min(max_scroll, scroll_offset + scroll_speed);
    }
}

// Auto-scroll to bottom when new messages arrive (if we were already at bottom)
if (array_length(combat_messages) > max_visible_messages) {
    var max_scroll = max(0, array_length(combat_messages) - max_visible_messages);
    var was_at_bottom = (scroll_offset >= max_scroll - 1);  // Allow small tolerance
    
    if (was_at_bottom) {
        scroll_offset = max_scroll;
    }
}