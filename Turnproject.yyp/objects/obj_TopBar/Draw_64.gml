// Top Bar System - Draw GUI Event

// Draw bar background
draw_set_alpha(log_background_alpha);
draw_rectangle_color(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw bar border
var border_color = mouse_over_bar ? c_yellow : c_white;
draw_rectangle_color(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, border_color, border_color, border_color, border_color, true);

// Mode indicator in top-right corner
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
var mode_text = "";
switch (current_mode) {
    case TOPBAR_MODE.COMBAT_LOG: mode_text = "LOG [TAB]"; break;
    case TOPBAR_MODE.ACTION_MENU: mode_text = "MENU [TAB]"; break;
    case TOPBAR_MODE.PLACEMENT_MODE: mode_text = "PLACEMENT"; break;
}
draw_text_transformed(bar_x + bar_width - 5, bar_y + 5, mode_text, 0.8, 0.8, 0);

// Display content based on current mode
switch (current_mode) {
    case TOPBAR_MODE.COMBAT_LOG:
        draw_combat_log();
        break;
    case TOPBAR_MODE.ACTION_MENU:
        draw_action_menu();
        break;
    case TOPBAR_MODE.PLACEMENT_MODE:
        draw_placement_mode();
        break;
}

// Reset drawing settings
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

// Function to draw combat log
function draw_combat_log() {
    if (array_length(combat_messages) == 0) {
        draw_set_color(c_gray);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_text_transformed(bar_x + 10, bar_y + bar_height/2, "Combat Log - No messages yet [Mouse wheel or ↑↓ to scroll]", 0.8, 0.8, 0);
        return;
    }
    
    // Calculate which messages to show based on scroll offset
    var total_messages = array_length(combat_messages);
    var max_scroll = max(0, total_messages - max_display_messages);
    
    // Show most recent messages by default, but allow scrolling back
    var start_index = max(0, total_messages - max_display_messages - log_scroll_offset);
    var end_index = min(total_messages, start_index + max_display_messages);
    
    var display_y = bar_y + 8;
    var messages_drawn = 0;
    
    for (var i = start_index; i < end_index && messages_drawn < max_display_messages; i++) {
        var message = combat_messages[i];
        var text_color = get_message_color(message);
        
        draw_set_color(text_color);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Clip text to fit in bar width
        var text_width = bar_width - 120; // Leave space for mode indicator and scroll info
        var clipped_message = string_copy(message, 1, floor(text_width / 7)); // Better character estimate
        
        draw_text_transformed(bar_x + 10, display_y + (messages_drawn * message_height), clipped_message, 0.8, 0.8, 0);
        messages_drawn++;
    }
    
    // Show scroll indicator if there are more messages
    if (total_messages > max_display_messages) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        var scroll_info = string(max(0, total_messages - log_scroll_offset - max_display_messages)) + "/" + string(total_messages);
        if (log_scroll_offset > 0) {
            scroll_info += " [↑↓]";
        }
        draw_text_transformed(bar_x + bar_width - 80, bar_y + bar_height - 5, scroll_info, 0.6, 0.6, 0);
    }
}

// Function to draw action menu
function draw_action_menu() {
    var active_player = get_active_player();
    
    // Compact layout for 80px top bar - smaller directional buttons
    var buttons_start_x = bar_x + 15;
    var button_y = bar_y + 15; // Higher up to avoid character names
    var dir_btn_size = 28; // Smaller directional buttons
    var action_btn_size = 36; // Medium action buttons  
    var btn_margin = 4;
    
    // Draw directional buttons in a compact cross pattern
    draw_directional_button(buttons_start_x + dir_btn_size + btn_margin, button_y - 12, "up", "up", active_player, dir_btn_size);        // Top
    draw_directional_button(buttons_start_x, button_y + 4, "left", "left", active_player, dir_btn_size);                              // Left
    draw_directional_button(buttons_start_x + (dir_btn_size + btn_margin) * 2, button_y + 4, "right", "right", active_player, dir_btn_size); // Right
    draw_directional_button(buttons_start_x + dir_btn_size + btn_margin, button_y + 20, "down", "down", active_player, dir_btn_size);  // Bottom
    
    // Action buttons (to the right of directional pad)
    var action_x = buttons_start_x + (dir_btn_size + btn_margin) * 3 + 20;
    draw_action_button(action_x, button_y, "WAIT", "wait", active_player, action_btn_size);
    draw_action_button(action_x + action_btn_size + btn_margin, button_y, "DEFEND", "defend", active_player, action_btn_size);
    
    // Turn order display (far right)
    draw_turn_order();
    
    // Player status info (left side, at bottom of bar)
    if (active_player != noone) {
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        var status_text = active_player.character_name + " | Moves: " + string(active_player.moves) + " | HP: " + string(active_player.hp) + "/" + string(active_player.max_hp);
        draw_text_transformed(buttons_start_x, bar_y + bar_height - 3, status_text, 0.7, 0.7, 0);
    }
}

// Helper function to draw directional buttons
function draw_directional_button(btn_x, btn_y, symbol, action, player, btn_size = 40) {
    var can_act = (player != noone && player.state == TURNSTATE.active && player.moves > 0 && !player.is_anim);
    var has_enemy = false;
    var can_move = false;
    
    if (can_act) {
        // Check if there's an enemy in this direction using enemy's mask at a point
        // NOTE: instance_place here would use obj_TopBar's mask, which is incorrect
        switch (action) {
            case "up": 
                has_enemy = instance_position(player.x, player.y - 16, obj_Enemy) != noone;
                can_move = true; // Simplify for now - just check if action is possible
                if (has_enemy) {
                    show_debug_message("UP: Enemy detected at " + string(player.x) + "," + string(player.y - 16));
                }
                break;
            case "down": 
                has_enemy = instance_position(player.x, player.y + 16, obj_Enemy) != noone;
                can_move = true;
                if (has_enemy) {
                    show_debug_message("DOWN: Enemy detected at " + string(player.x) + "," + string(player.y + 16));
                }
                break;
            case "left": 
                has_enemy = instance_position(player.x - 16, player.y, obj_Enemy) != noone;
                can_move = true;
                if (has_enemy) {
                    show_debug_message("LEFT: Enemy detected at " + string(player.x - 16) + "," + string(player.y));
                }
                break;
            case "right": 
                has_enemy = instance_position(player.x + 16, player.y, obj_Enemy) != noone;
                can_move = true;
                if (has_enemy) {
                    show_debug_message("RIGHT: Enemy detected at " + string(player.x + 16) + "," + string(player.y));
                }
                break;
        }
    }
    
    // Button background color based on action availability
    var bg_color = c_dkgray; // Default: cannot act
    if (can_act) {
        if (has_enemy) {
            bg_color = c_red;        // ATTACK: Enemy present - RED (always valid)
            show_debug_message("BUTTON " + action + ": RED (has_enemy=" + string(has_enemy) + ", can_move=" + string(can_move) + ")");
        } else if (can_move) {
            bg_color = c_green;      // MOVE: Path clear - GREEN  
            show_debug_message("BUTTON " + action + ": GREEN (has_enemy=" + string(has_enemy) + ", can_move=" + string(can_move) + ")");
        } else {
            bg_color = c_gray;       // BLOCKED: Can act but path blocked - GRAY
            show_debug_message("BUTTON " + action + ": GRAY (has_enemy=" + string(has_enemy) + ", can_move=" + string(can_move) + ")");
        }
    } else {
        show_debug_message("BUTTON " + action + ": DARK_GRAY (can_act=" + string(can_act) + ")");
    }
    
    // Highlight if clicked recently
    if (clicked_button == action) bg_color = c_yellow;
    
    // Use the passed btn_size parameter
    draw_set_alpha(0.7);
    draw_rectangle_color(btn_x, btn_y, btn_x + btn_size, btn_y + btn_size, bg_color, bg_color, bg_color, bg_color, false);
    draw_set_alpha(1);
    draw_rectangle_color(btn_x, btn_y, btn_x + btn_size, btn_y + btn_size, c_white, c_white, c_white, c_white, true);
    
    // Draw arrow symbols using simple ASCII
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var arrow_symbol = "";
    switch (action) {
        case "up": arrow_symbol = "^"; break;
        case "down": arrow_symbol = "v"; break;
        case "left": arrow_symbol = "<"; break;
        case "right": arrow_symbol = ">"; break;
    }
    draw_text_transformed(btn_x + btn_size/2, btn_y + btn_size/2, arrow_symbol, 1.8, 1.8, 0);
}

// Helper function to draw action buttons
function draw_action_button(btn_x, btn_y, text, action, player, btn_size = 40) {
    var can_act = (player != noone && player.state == TURNSTATE.active && player.moves > 0 && !player.is_anim);
    var bg_color = can_act ? c_blue : c_dkgray;
    
    // Highlight if clicked recently
    if (clicked_button == action) bg_color = c_yellow;
    
    // Use the passed btn_size parameter
    draw_set_alpha(0.7);
    draw_rectangle_color(btn_x, btn_y, btn_x + btn_size, btn_y + btn_size, bg_color, bg_color, bg_color, bg_color, false);
    draw_set_alpha(1);
    draw_rectangle_color(btn_x, btn_y, btn_x + btn_size, btn_y + btn_size, c_white, c_white, c_white, c_white, true);
    
    // Draw text
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(btn_x + btn_size/2, btn_y + btn_size/2, text, 0.5, 0.5, 0);
}

// Helper function to draw turn order
function draw_turn_order() {
    var turn_order = get_turn_order(6); // Get next 6 characters (current + 5)
    if (array_length(turn_order) == 0) return;
    
    var start_x = bar_x + bar_width - turn_display_width - 10;
    var start_y = bar_y + 8;
    var char_width = turn_character_width;
    var char_height = bar_height - 16; // More space in 80px bar
    
    for (var i = 0; i < min(6, array_length(turn_order)); i++) {
        var character = turn_order[i];
        if (!instance_exists(character)) continue;
        
        var char_x = start_x + (i * char_width);
        var is_current = (i == 0);
        
        // Character background
        var bg_color = is_current ? c_yellow : c_gray;
        draw_set_alpha(0.6);
        draw_rectangle_color(char_x, start_y, char_x + char_width - 2, start_y + char_height, bg_color, bg_color, bg_color, bg_color, false);
        draw_set_alpha(1);
        
        // Character border
        var border_color = is_current ? c_white : c_ltgray;
        draw_rectangle_color(char_x, start_y, char_x + char_width - 2, start_y + char_height, border_color, border_color, border_color, border_color, true);
        
        // Portrait preferred for players; else fallback to sprite or color block
        var drew_image = false;
        if (object_get_name(character.object_index) == "obj_Player") {
            var sprp = portraits_get_sprite_for_entity(character);
            if (sprp != -1) {
                var px1 = char_x + 1;
                var py1 = start_y + 1;
                var px2 = char_x + char_width - 3;
                var py2 = start_y + char_height - 12; // Leave space for name at bottom
                drew_image = portraits_draw_fit(sprp, px1, py1, px2, py2);
            }
        }
        if (!drew_image && variable_instance_exists(character, "sprite_index") && character.sprite_index != -1) {
            var sprite_scale = 0.8;
            var sprite_x = char_x + char_width/2;
            var sprite_y = start_y + char_height/2 - 5;
            draw_sprite_ext(character.sprite_index, 0, sprite_x, sprite_y, sprite_scale, sprite_scale, 0, c_white, 1);
            drew_image = true;
        }
        if (!drew_image) {
            // Fallback: draw colored rectangle
            var entity_color = (object_get_name(character.object_index) == "obj_Player") ? c_blue : c_red;
            draw_set_alpha(0.8);
            draw_rectangle_color(char_x + 5, start_y + 5, char_x + char_width - 7, start_y + char_height - 15, entity_color, entity_color, entity_color, entity_color, false);
            draw_set_alpha(1);
        }
        
        // Character name
        draw_set_color(is_current ? c_black : c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        var name_text = string_copy(character.character_name, 1, 8); // Truncate long names
        draw_text_transformed(char_x + char_width/2, start_y + char_height - 2, name_text, 0.5, 0.5, 0);
        
        // Turn indicator
        if (is_current) {
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_text_transformed(char_x + char_width/2, start_y + 2, "▼", 0.8, 0.8, 0);
        }
    }
}

// Helper function to get message color (from original combat log)
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

// Function to draw placement mode
function draw_placement_mode() {
    var placement_ui = instance_find(obj_PlacementUI, 0);
    if (placement_ui == noone) {
        draw_set_color(c_red);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_text_transformed(bar_x + 10, bar_y + bar_height/2, "Placement mode error - no placement UI found", 1, 1, 0);
        return;
    }
    
    // Show placement status and instructions
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var instructions = "CREW PLACEMENT - Click and drag to position your crew members";
    draw_text_transformed(bar_x + 10, bar_y + 8, instructions, 0.8, 0.8, 0);
    
    // Show current character being placed
    if (placement_ui.current_character_index < array_length(placement_ui.crew_to_place)) {
        var current_crew = placement_ui.crew_to_place[placement_ui.current_character_index];
        var progress_text = "Placing: " + current_crew.crew_member.full_name + " (" + string(placement_ui.current_character_index + 1) + "/" + string(array_length(placement_ui.crew_to_place)) + ")";
        
        draw_set_color(c_yellow);
        draw_text_transformed(bar_x + 10, bar_y + 24, progress_text, 0.7, 0.7, 0);
    }
    
    // Show completion status
    var placed_count = 0;
    for (var i = 0; i < array_length(placement_ui.crew_to_place); i++) {
        if (placement_ui.crew_to_place[i].placed) {
            placed_count++;
        }
    }
    
    draw_set_color(c_lime);
    draw_set_halign(fa_right);
    var completion_text = "Ready: " + string(placed_count) + "/" + string(array_length(placement_ui.crew_to_place));
    if (placed_count == array_length(placement_ui.crew_to_place)) {
        completion_text += " - Press ENTER to start combat!";
    }
    draw_text_transformed(bar_x + bar_width - 10, bar_y + 40, completion_text, 0.7, 0.7, 0);
}
