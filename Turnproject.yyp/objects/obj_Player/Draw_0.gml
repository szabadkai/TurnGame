// Use inherited drawing from base class
event_inherited();

// Draw click-to-move indicators when it's player's turn
if (state == TURNSTATE.active && moves > 0 && !is_anim) {
    // Calculate adjacent grid positions
    var adjacent_positions = [
        {x: x + 16, y: y, valid: can_move_to(x + 16, y)},
        {x: x - 16, y: y, valid: can_move_to(x - 16, y)},
        {x: x, y: y + 16, valid: can_move_to(x, y + 16)},
        {x: x, y: y - 16, valid: can_move_to(x, y - 16)}
    ];
    
    // Draw movement indicators for valid positions
    for (var i = 0; i < array_length(adjacent_positions); i++) {
        var pos = adjacent_positions[i];
        if (pos.valid) {
            // Check if mouse is hovering over this position
            var mouse_grid_x = floor(mouse_x / 16) * 16 + 8;
            var mouse_grid_y = floor(mouse_y / 16) * 16 + 8;
            var is_hovered = (mouse_grid_x == pos.x && mouse_grid_y == pos.y);
            
            // Draw movement indicator
            draw_set_alpha(is_hovered ? 0.8 : 0.3);
            draw_set_color(is_hovered ? c_yellow : c_lime);
            draw_circle(pos.x, pos.y, 4, true);
            
            if (is_hovered) {
                draw_circle(pos.x, pos.y, 6, true);
            }
        }
    }
    
    // Reset draw settings
    draw_set_alpha(1.0);
    draw_set_color(c_white);
}