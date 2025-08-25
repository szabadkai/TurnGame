// Top Bar System - Create Event
// Combines combat log and action menu in a fixed top bar

// Display modes
enum TOPBAR_MODE {
    COMBAT_LOG,
    ACTION_MENU,
    PLACEMENT_MODE
}

// Initialize display mode
current_mode = TOPBAR_MODE.COMBAT_LOG;

// Bar dimensions - increased height for better layout
bar_height = 80;
bar_width = display_get_gui_width();
bar_x = 0;
bar_y = 0;

// Combat log variables (simplified from obj_CombatLog)
combat_messages = [];
max_display_messages = 4; // Fixed number for expanded top bar
message_height = 16;
log_background_alpha = 0.8;
log_scroll_offset = 0; // For scrolling through messages

// Action menu variables
button_size = 40;
button_margin = 8;
turn_display_width = 300;
turn_character_width = 50;

// Mouse interaction
mouse_over_bar = false;
clicked_button = "";

// Initialize global combat log function if not already done
if (!variable_global_exists("combat_log")) {
    global.combat_log = function(message) {
        if (instance_exists(obj_TopBar)) {
            var bar_instance = instance_find(obj_TopBar, 0);
            array_push(bar_instance.combat_messages, message);
            
            // Keep only recent messages for top bar display
            if (array_length(bar_instance.combat_messages) > 20) {
                array_delete(bar_instance.combat_messages, 0, 1);
            }
        }
    }
}

// Helper function to get current active player
function get_active_player() {
    var player_count = instance_number(obj_Player);
    for (var i = 0; i < player_count; i++) {
        var player = instance_find(obj_Player, i);
        if (instance_exists(player) && player.state == TURNSTATE.active) {
            return player;
        }
    }
    return noone;
}

// Helper function to get turn order from TurnManager
function get_turn_order(max_count) {
    var turn_order = [];
    
    if (instance_exists(obj_TurnManager) && ds_exists(obj_TurnManager.turn_list, ds_type_list)) {
        var turn_list = obj_TurnManager.turn_list;
        var list_size = ds_list_size(turn_list);
        
        for (var i = 0; i < min(max_count, list_size); i++) {
            var character = turn_list[| i];
            if (instance_exists(character)) {
                array_push(turn_order, character);
            }
        }
    }
    
    return turn_order;
}

show_debug_message("TopBar initialized in COMBAT_LOG mode");