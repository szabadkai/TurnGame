// Combat log system
combat_messages = [];
max_messages = 50;  // Store more messages for scrolling
message_height = 16;
log_background_alpha = 0.7;

// Collapse state management
enum LOG_STATE {
    FULL,
    ONELINE,
    NUB
}

log_state = LOG_STATE.FULL;
max_visible_messages = 8;  // How many messages to show in full state

// Scrolling system
scroll_offset = 0;
scroll_speed = 1;  // Messages to scroll per wheel tick

// UI interaction
mouse_over_log = false;
nub_size = 20;
collapse_button_size = 16;

// Calculate log dimensions once
function update_log_dimensions() {
    viewport_width = display_get_gui_width();
    viewport_height = display_get_gui_height();
    
    log_width = viewport_width - 20;
    
    switch(log_state) {
        case LOG_STATE.FULL:
            log_height = max_visible_messages * message_height;
            break;
        case LOG_STATE.ONELINE:
            log_height = message_height;
            break;
        case LOG_STATE.NUB:
            log_height = nub_size;
            break;
    }
    
    log_x = 10;
    log_y = viewport_height - log_height - 20;
}

// Initialize global combat log function
global.combat_log = function(message) {
    if (instance_exists(obj_CombatLog)) {
        var log_instance = instance_find(obj_CombatLog, 0);
        array_push(log_instance.combat_messages, message);
        
        // Keep more messages for scrolling, but clean up when too many
        if (array_length(log_instance.combat_messages) > log_instance.max_messages) {
            array_delete(log_instance.combat_messages, 0, 1);
            // Adjust scroll if we're at the bottom
            if (log_instance.scroll_offset > 0) {
                log_instance.scroll_offset = max(0, log_instance.scroll_offset - 1);
            }
        }
    }
}