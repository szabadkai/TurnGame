// Top Bar System - Step Event

// Update bar dimensions for responsive layout
bar_width = display_get_gui_width();

// Check mouse interaction
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
mouse_over_bar = point_in_rectangle(mx, my, bar_x, bar_y, bar_x + bar_width, bar_y + bar_height);

// Check if we're in placement mode
var placement_ui = instance_find(obj_PlacementUI, 0);
var in_placement = (placement_ui != noone && placement_ui.placement_active);

// Handle mode toggle (TAB key) - don't allow mode switching during placement
if (keyboard_check_pressed(vk_tab) && !in_placement) {
    if (current_mode == TOPBAR_MODE.COMBAT_LOG) {
        current_mode = TOPBAR_MODE.ACTION_MENU;
        show_debug_message("TopBar switched to ACTION_MENU mode");
    } else {
        current_mode = TOPBAR_MODE.COMBAT_LOG;
        show_debug_message("TopBar switched to COMBAT_LOG mode");
    }
}

// Force placement mode when placement is active
if (in_placement && current_mode != TOPBAR_MODE.PLACEMENT_MODE) {
    current_mode = TOPBAR_MODE.PLACEMENT_MODE;
    show_debug_message("TopBar switched to PLACEMENT_MODE");
    
    // Hide the placement UI's own drawing to prevent overlap
    if (placement_ui != noone) {
        placement_ui.visible = false;
    }
}

// Exit placement mode when placement is done
if (!in_placement && current_mode == TOPBAR_MODE.PLACEMENT_MODE) {
    current_mode = TOPBAR_MODE.ACTION_MENU;
    show_debug_message("TopBar exited PLACEMENT_MODE to ACTION_MENU");
}

// Combat log scrolling (only in LOG mode and when mouse is over bar)
if (current_mode == TOPBAR_MODE.COMBAT_LOG && mouse_over_bar) {
    var wheel_up = mouse_wheel_up();
    var wheel_down = mouse_wheel_down();
    
    if (wheel_up || keyboard_check_pressed(vk_up)) {
        log_scroll_offset = max(0, log_scroll_offset - 1);
    }
    
    if (wheel_down || keyboard_check_pressed(vk_down)) {
        var max_scroll = max(0, array_length(combat_messages) - max_display_messages);
        log_scroll_offset = min(max_scroll, log_scroll_offset + 1);
    }
}

// Action menu input handling
if (current_mode == TOPBAR_MODE.ACTION_MENU) {
    var active_player = get_active_player();
    
    // Only handle action menu inputs if there's an active player
    if (active_player != noone && active_player.state == TURNSTATE.active && active_player.moves > 0 && !active_player.is_anim) {
        
        // Handle button clicks - match the draw layout exactly
        if (mouse_check_button_pressed(mb_left) && mouse_over_bar) {
            var buttons_start_x = bar_x + 15;
            var button_y = bar_y + 15; // Higher up to avoid character names
            var dir_btn_size = 28; // Smaller directional buttons
            var action_btn_size = 36; // Medium action buttons  
            var btn_margin = 4;
            
            // Up button
            if (point_in_rectangle(mx, my, buttons_start_x + dir_btn_size + btn_margin, button_y - 12, 
                                   buttons_start_x + dir_btn_size + btn_margin + dir_btn_size, button_y - 12 + dir_btn_size)) {
                clicked_button = "up";
                trigger_player_action(active_player, "up");
            }
            // Down button
            else if (point_in_rectangle(mx, my, buttons_start_x + dir_btn_size + btn_margin, button_y + 20, 
                                        buttons_start_x + dir_btn_size + btn_margin + dir_btn_size, button_y + 20 + dir_btn_size)) {
                clicked_button = "down";
                trigger_player_action(active_player, "down");
            }
            // Left button
            else if (point_in_rectangle(mx, my, buttons_start_x, button_y + 4, 
                                        buttons_start_x + dir_btn_size, button_y + 4 + dir_btn_size)) {
                clicked_button = "left";
                trigger_player_action(active_player, "left");
            }
            // Right button
            else if (point_in_rectangle(mx, my, buttons_start_x + (dir_btn_size + btn_margin) * 2, button_y + 4, 
                                        buttons_start_x + (dir_btn_size + btn_margin) * 2 + dir_btn_size, button_y + 4 + dir_btn_size)) {
                clicked_button = "right";
                trigger_player_action(active_player, "right");
            }
            // Wait button
            else if (point_in_rectangle(mx, my, buttons_start_x + (dir_btn_size + btn_margin) * 3 + 20, button_y, 
                                        buttons_start_x + (dir_btn_size + btn_margin) * 3 + 20 + action_btn_size, button_y + action_btn_size)) {
                clicked_button = "wait";
                trigger_player_action(active_player, "wait");
            }
            // Defend button
            else if (point_in_rectangle(mx, my, buttons_start_x + (dir_btn_size + btn_margin) * 3 + 20 + action_btn_size + btn_margin, button_y, 
                                        buttons_start_x + (dir_btn_size + btn_margin) * 3 + 20 + action_btn_size + btn_margin + action_btn_size, button_y + action_btn_size)) {
                clicked_button = "defend";
                trigger_player_action(active_player, "defend");
            }
        }
    }
}

// Helper function to trigger player actions
function trigger_player_action(player, action) {
    if (!instance_exists(player)) return;
    
    switch (action) {
        case "up":
            var enemy_up = instance_position(player.x, player.y - 16, obj_Enemy);
            if (enemy_up != noone) {
                // Attack enemy above
                player.target_enemy = enemy_up;
                player.dir = Dir.UP;
                player.anim_state = State.ATTACK;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
                player.depth = -100;
                scr_log(player.character_name + " attacks UP!");
            } else if (player.can_move_to(player.x, player.y - 16)) {
                // Move up
                player.dir = Dir.UP;
                player.anim_state = State.RUN;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
                scr_log(player.character_name + " moves UP!");
            }
            break;
            
        case "down":
            var enemy_down = instance_position(player.x, player.y + 16, obj_Enemy);
            if (enemy_down != noone) {
                // Attack enemy below
                player.target_enemy = enemy_down;
                player.dir = Dir.DOWN;
                player.anim_state = State.ATTACK;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
                player.depth = -100;
            } else if (player.can_move_to(player.x, player.y + 16)) {
                // Move down
                player.dir = Dir.DOWN;
                player.anim_state = State.RUN;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
            }
            break;
            
        case "left":
            var enemy_left = instance_position(player.x - 16, player.y, obj_Enemy);
            if (enemy_left != noone) {
                // Attack enemy to the left
                player.target_enemy = enemy_left;
                player.dir = Dir.LEFT;
                player.anim_state = State.ATTACK;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
                player.depth = -100;
            } else if (player.can_move_to(player.x - 16, player.y)) {
                // Move left
                player.dir = Dir.LEFT;
                player.anim_state = State.RUN;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
            }
            break;
            
        case "right":
            var enemy_right = instance_position(player.x + 16, player.y, obj_Enemy);
            if (enemy_right != noone) {
                // Attack enemy to the right
                player.target_enemy = enemy_right;
                player.dir = Dir.RIGHT;
                player.anim_state = State.ATTACK;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
                player.depth = -100;
            } else if (player.can_move_to(player.x + 16, player.y)) {
                // Move right
                player.dir = Dir.RIGHT;
                player.anim_state = State.RUN;
                player.sprite_index = player.spr_matrix[player.dir][player.anim_state];
                player.image_index = 0;
                player.image_speed = 1.0;
                player.is_anim = true;
            }
            break;
            
        case "wait":
            // End turn by setting moves to 0
            player.moves = 0;
            player.alarm[0] = 1; // Trigger turn end
            scr_log(player.character_name + " waits and ends turn.");
            break;
            
        case "defend":
            // Implement defend action - boost defense for this turn
            if (!variable_instance_exists(player, "is_defending")) {
                player.is_defending = false;
            }
            player.is_defending = true;
            player.moves = 0; // End turn after defending
            player.alarm[0] = 1;
            scr_log(player.character_name + " takes a defensive stance (+2 AC until next turn).");
            break;
    }
}

// Clear clicked button after a short time
if (clicked_button != "" && current_time > 0) {
    clicked_button = "";
}
