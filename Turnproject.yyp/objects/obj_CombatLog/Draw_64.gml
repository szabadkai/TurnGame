// Draw combat log based on current state
if (array_length(combat_messages) > 0 || log_state == LOG_STATE.NUB) {
    
    switch(log_state) {
        case LOG_STATE.FULL:
            draw_full_log();
            break;
        case LOG_STATE.ONELINE:
            draw_oneline_log();
            break;
        case LOG_STATE.NUB:
            draw_nub_log();
            break;
    }
}

// Function to draw full log with scrolling
function draw_full_log() {
    // Draw semi-transparent background
    draw_set_alpha(log_background_alpha);
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // Draw border
    var border_color = mouse_over_log ? c_yellow : c_white;
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, border_color, border_color, border_color, border_color, true);
    
    // Draw collapse button
    draw_collapse_button();
    
    // Draw messages with scrolling
    if (array_length(combat_messages) > 0) {
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        var messages_to_show = min(array_length(combat_messages), max_visible_messages);
        // Show newest messages by default, scroll back through history
        var total_messages = array_length(combat_messages);
        var start_index = max(0, total_messages - max_visible_messages - scroll_offset);
        
        for (var i = 0; i < messages_to_show; i++) {
            var message_index = start_index + i;
            if (message_index >= array_length(combat_messages)) break;
            
            var y_pos = log_y + (i * message_height);
            var message = combat_messages[message_index];
            
            // Color code messages
            var text_color = get_message_color(message);
            draw_set_color(text_color);
            
            // Clip text to fit in log area
            var text_width = log_width - collapse_button_size - 10;
            var clipped_message = string_copy(message, 1, floor(text_width / 8));  // Rough character estimate
            
            draw_text_transformed(log_x, y_pos, clipped_message, 0.8, 0.8, 0);
        }
        
        // Draw scroll indicator if needed
        if (array_length(combat_messages) > max_visible_messages) {
            draw_scroll_indicator();
        }
    }
}

// Function to draw one-line log
function draw_oneline_log() {
    // Draw semi-transparent background
    draw_set_alpha(log_background_alpha);
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // Draw border
    var border_color = mouse_over_log ? c_yellow : c_white;
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, border_color, border_color, border_color, border_color, true);
    
    // Draw collapse button
    draw_collapse_button();
    
    // Draw most recent message
    if (array_length(combat_messages) > 0) {
        var latest_message = combat_messages[array_length(combat_messages) - 1];
        var text_color = get_message_color(latest_message);
        
        draw_set_color(text_color);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Add "..." if there are more messages
        var display_message = string(latest_message);
        if (array_length(combat_messages) > 1) {
            display_message = "..." + string(latest_message);
        }
        
        // Clip text to fit
        var text_width = log_width - collapse_button_size - 10;
        var clipped_message = string_copy(display_message, 1, floor(text_width / 8));
        
        draw_text_transformed(log_x, log_y, clipped_message, 0.8, 0.8, 0);
    }
}

// Function to draw nub state
function draw_nub_log() {
    // Draw small nub button
    draw_set_alpha(log_background_alpha);
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + nub_size + 5, log_y + nub_size + 5, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    var border_color = mouse_over_log ? c_yellow : c_white;
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + nub_size + 5, log_y + nub_size + 5, border_color, border_color, border_color, border_color, true);
    
    // Draw "LOG" text or icon
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(log_x + nub_size/2, log_y + nub_size/2, "LOG", 0.6, 0.6, 0);
}

// Helper function to get message color
function get_message_color(message) {
    if (string_pos("HIT!", message) > 0) {
        return c_lime;
    } else if (string_pos("MISS!", message) > 0) {
        return c_red;
    } else if (string_pos("damage", message) > 0) {
        return c_yellow;
    } else if (string_pos("CRITICAL", message) > 0 || string_pos("CHAIN", message) > 0) {
        return c_orange;
    }
    return c_white;
}

// Helper function to draw collapse button
function draw_collapse_button() {
    var btn_x = log_x + log_width - collapse_button_size;
    var btn_y = log_y - 5;
    
    // Button background
    draw_set_alpha(0.8);
    draw_rectangle_color(btn_x, btn_y, btn_x + collapse_button_size, btn_y + collapse_button_size, c_gray, c_gray, c_gray, c_gray, false);
    draw_set_alpha(1);
    
    // Button border
    draw_rectangle_color(btn_x, btn_y, btn_x + collapse_button_size, btn_y + collapse_button_size, c_white, c_white, c_white, c_white, true);
    
    // Button symbol based on state
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var symbol = "";
    switch(log_state) {
        case LOG_STATE.FULL: symbol = "−"; break;     // Minimize
        case LOG_STATE.ONELINE: symbol = "_"; break;  // To nub
        case LOG_STATE.NUB: symbol = "+"; break;      // Expand
    }
    
    draw_text_transformed(btn_x + collapse_button_size/2, btn_y + collapse_button_size/2, symbol, 1, 1, 0);
}

// Helper function to draw scroll indicator
function draw_scroll_indicator() {
    if (array_length(combat_messages) <= max_visible_messages) return;
    
    var indicator_x = log_x + log_width - 8;
    var indicator_y = log_y;
    var indicator_height = log_height;
    
    // Scroll track
    draw_set_alpha(0.3);
    draw_rectangle_color(indicator_x, indicator_y, indicator_x + 6, indicator_y + indicator_height, c_white, c_white, c_white, c_white, false);
    draw_set_alpha(1);
    
    // Scroll thumb
    var total_messages = array_length(combat_messages);
    var thumb_height = max(10, (max_visible_messages / total_messages) * indicator_height);
    var max_scroll = max(1, total_messages - max_visible_messages);
    var thumb_y = indicator_y + ((max_scroll - scroll_offset) / max_scroll) * (indicator_height - thumb_height);
    
    draw_rectangle_color(indicator_x + 1, thumb_y, indicator_x + 5, thumb_y + thumb_height, c_yellow, c_yellow, c_yellow, c_yellow, false);
}

// Reset drawing settings
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);