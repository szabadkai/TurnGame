// Draw combat log on GUI layer - always at bottom of viewport
if (array_length(combat_messages) > 0) {
    // Calculate positions based on current viewport/camera
    var viewport_width = display_get_gui_width();
    var viewport_height = display_get_gui_height();
    
    var log_width = viewport_width - 20;
    var log_height = max_messages * message_height;
    var log_x = 10;
    var log_y = viewport_height - log_height - 20;
    
    // Draw semi-transparent background
    draw_set_alpha(log_background_alpha);
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(1);
    
    // Draw border
    draw_rectangle_color(log_x - 5, log_y - 5, log_x + log_width + 5, log_y + log_height + 5, c_white, c_white, c_white, c_white, true);
    
    // Draw messages
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var messages_to_show = min(array_length(combat_messages), max_messages);
    var start_index = max(0, array_length(combat_messages) - max_messages);
    
    for (var i = 0; i < messages_to_show; i++) {
        var message_index = start_index + i;
        var y_pos = log_y + (i * message_height);
        
        // Color code different types of messages
        var message = combat_messages[message_index];
        var text_color = c_white;
        
        if (string_pos("HIT!", message) > 0) {
            text_color = c_lime;
        } else if (string_pos("MISS!", message) > 0) {
            text_color = c_red;
        } else if (string_pos("damage", message) > 0) {
            text_color = c_yellow;
        } else if (string_pos("CRITICAL", message) > 0 || string_pos("CHAIN", message) > 0) {
            text_color = c_orange;
        }
        
        draw_set_color(text_color);
        draw_text_transformed(log_x, y_pos, message, 0.8, 0.8, 0);
    }
    
    // Reset drawing settings
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}