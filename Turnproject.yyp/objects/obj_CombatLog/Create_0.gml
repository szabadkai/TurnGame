// Combat log system
combat_messages = [];
max_messages = 8;  // Show last 8 messages
message_height = 16;
log_background_alpha = 0.7;

// Initialize global combat log function
global.combat_log = function(message) {
    if (instance_exists(obj_CombatLog)) {
        var log_instance = instance_find(obj_CombatLog, 0);
        array_push(log_instance.combat_messages, message);
        
        // Remove old messages if we exceed max
        if (array_length(log_instance.combat_messages) > log_instance.max_messages) {
            array_delete(log_instance.combat_messages, 0, 1);
        }
    }
}